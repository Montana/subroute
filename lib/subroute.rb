require 'rack'
require 'logger'
require 'optparse'

module Subroute
  class Configuration
    attr_accessor :root, :port, :host, :logger

    def initialize
      @root = File.expand_path("~/.subroute")
      @port = 80
      @host = '0.0.0.0'
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  class App
    def initialize
      @logger = Subroute.configuration.logger
    end

    def call(env)
      host = env['HTTP_HOST'].split(':').first
      app_name = host.sub('.test', '')
      app_path = File.join(Subroute.configuration.root, app_name)

      @logger.info("Request received for #{app_name}.test")

      if File.symlink?(app_path)
        handle_symlink(app_path, env)
      else
        @logger.warn("No app found for #{app_name}.test")
        [404, {"Content-Type" => "text/plain"}, ["No app found for #{app_name}.test"]]
      end
    rescue => e
      @logger.error("Error processing request: #{e.message}")
      [500, {"Content-Type" => "text/plain"}, ["Internal Server Error: #{e.message}"]]
    end

    private

    def handle_symlink(app_path, env)
      rack_app_path = File.readlink(app_path)
      config_ru = File.join(rack_app_path, 'config.ru')

      if File.exist?(config_ru)
        @logger.info("Loading app from #{rack_app_path}")
        app = Rack::Builder.parse_file(config_ru)
        app.call(env)
      else
        @logger.error("Missing config.ru in #{rack_app_path}")
        [500, {"Content-Type" => "text/plain"}, ["Missing config.ru in #{rack_app_path}"]]
      end
    end
  end

  def self.run
    parse_options
    setup_environment
    start_server
  end

  private

  def self.parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: subroute [options]"

      opts.on("-p", "--port PORT", Integer, "Port to run on (default: 80)") do |port|
        configuration.port = port
      end

      opts.on("-r", "--root ROOT", "Root directory for apps (default: ~/.subroute)") do |root|
        configuration.root = File.expand_path(root)
      end

      opts.on("-h", "--host HOST", "Host to bind to (default: 0.0.0.0)") do |host|
        configuration.host = host
      end

      opts.on("-v", "--verbose", "Enable verbose logging") do
        configuration.logger.level = Logger::DEBUG
      end
    end.parse!
  end

  def self.setup_environment
    Dir.mkdir(configuration.root) unless Dir.exist?(configuration.root)
    configuration.logger.info("Subroute listening for *.test apps in #{configuration.root}")
  end

  def self.start_server
    Rack::Handler::WEBrick.run(
      App.new,
      Host: configuration.host,
      Port: configuration.port,
      Logger: configuration.logger,
      AccessLog: []
    )
  end
end