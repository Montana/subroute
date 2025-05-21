Gem::Specification.new do |s|
  s.name        = 'subroute'
  s.version     = '0.1.0'
  s.summary     = 'Zero-config local subdomain router for Rack apps'
  s.authors     = ['Your Name']
  s.files       = Dir['lib/**/*.rb'] + ['bin/subroute']
  s.executables << 'subroute'
  s.require_paths = ['lib']
  s.add_dependency 'rack'
end
