# Subroute

**Subroute** is a zero-config local development router for `.test` domains. It routes requests to Rack-based apps using subdomains.

> Access `http://myapp.test` and have it automatically served from `~/.subroute/myapp`.

##  DNS Setup (macOS/Linux)

```bash
brew install dnsmasq
echo "address=/.test/127.0.0.1" | sudo tee -a /usr/local/etc/dnsmasq.conf
sudo brew services start dnsmasq
sudo networksetup -setdnsservers Wi-Fi 127.0.0.1
```
## Run Subroute

```bash
./bin/subroute
```
## Visit App 

Visit your `.test` domain via going into a browser and running: 

```bash
http://myapp.test
```
Make sure it's obviously your own domain. 

## Authors

Michael Mendy (c) 2025. 
