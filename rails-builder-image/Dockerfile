# syntax=docker/dockerfile:1.3-labs 
FROM ruby:3-alpine
RUN apk --no-cache add bash build-base git
#RUN apk --no-cache add freetds-dev 
RUN gem install rails guard
RUN mkdir /app
WORKDIR /app

# https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/
COPY <<-"EOF" /tmp/options
  --force 
  --skip-action-cable 
  --skip-action-mailbox 
  --skip-action-text 
  --skip-active-storage 
  --skip-bootsnap 
  --skip-bundle 
  --skip-git
  --skip-javascript 
  --skip-system-test 
  --skip-test 
  --skip-turbolinks
  --asset-pipeline=propshaft
  --skip-active-record
EOF

# https://guides.rubyonrails.org/rails_application_templates.html
COPY <<-"EOF" /tmp/template.rb
  route "root to: 'home#index'"
  environment "config.web_console.whitelisted_ips = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16']", env: 'development'

  gem 'lograge'
  gem 'logstash-event'
  gem 'logstash-logger'
  gem "rufus-scheduler"

  gem_group :test do
    gem "selenium-webdriver"
    gem "capybara"
    gem "webdrivers"
    gem "rspec-rails"
    gem "rubocop-rspec"
  end

  gem_group :development do
    gem "rack-mini-profiler", require: false
    gem 'memory_profiler'
    gem 'stackprof'

    gem "brakeman"
    gem "bundler-audit"
    gem "rubocop-rails"

    gem "guard"
    gem "guard-puma"
    gem "guard-bundler"

    gem "better_errors"
    gem "binding_of_caller"
  end
EOF

CMD rails new . -m /tmp/template.rb --rc=/tmp/options