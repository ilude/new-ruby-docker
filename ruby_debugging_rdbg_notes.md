# Ruby [Debug](https://github.com/ruby/debug) setup 
steps are specific to projects generated using https://github.com/ilude/new-ruby-docker

#####(not working at this time)
see: https://github.com/ruby/vscode-rdbg/pull/42

## VSCode setup

Add extension [KoichiSasada.vscode-rdbg](https://marketplace.visualstudio.com/items?itemName=KoichiSasada.vscode-rdbg)

Add the following to .vscode/launch.json
```
{
  "configurations": [
    {
      "type": "rdbg",
      "name": "Attach with rdbg",
      "request": "attach",
      "debugPort": "12345",
      "sourceMappings": [
        {
          "remoteRoot": "/app",
          "localRoot": "./base"
        }
      ]  
    }
}
```
## Rails project setup

uncomment gem "debug" in Gemfile 

add the following to config/boot.rb
```
if ENV['RAILS_ENV'].eql?('development') && ENV['RUBY_DEBUG_PORT'].nil? == false
  # https://github.com/ruby/debug
  require 'debug/open_nonstop'
  puts "Rails Debugging enabled on port #{ENV['RUBY_DEBUG_PORT']}"
end
```

add the following to compose/docker-compose.development.yml
```
    environment:
      - RUBY_DEBUG_HOST=0.0.0.0
      - RUBY_DEBUG_LOG_LEVEL=WARN
    ports:
      - ${RUBY_DEBUG_PORT:-12345}:${RUBY_DEBUG_PORT:-12345}
      - 26162:26162
```

### Build and install VScode extension from github


in admin powershell:
```
# clone repo and switch to branch
git clone https://github.com/firien/vscode-rdbg.git
git branch --track multi-remote-boot origin/multi-remote-boot

# setup build environment
choco install nodejs -y
refreshenv
npm install -g vsce
npm install -g yarn
npm install -g typescript

# compile vscode extension and install
# https://stackoverflow.com/a/54409592
vsce package  # Generates a .vsix file
code --install-extension vscode-rdbg-0.0.10.vsix
```