# syntax=docker/dockerfile:1.3-labs # dockerfile heredoc https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/
FROM ruby:alpine
RUN apk --no-cache add bash build-base freetds-dev git
RUN gem install rails
RUN mkdir /app
WORKDIR /app

COPY <<EOF /tmp/options
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
CMD rails new . --rc=/tmp/options 