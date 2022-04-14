# syntax=docker/dockerfile:1.3-labs 
FROM ruby:3-alpine
RUN apk --no-cache add bash build-base freetds-dev git
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
  --database=sqlserver 
EOF

# https://guides.rubyonrails.org/rails_application_templates.html
COPY <<-"EOF" /tmp/template.rb
  gem_group :development do
    gem "guard"
    gem "guard-puma"
    gem "guard-bundler"
  end
EOF

CMD rails new . -m /tmp/template.rb --rc=/tmp/options