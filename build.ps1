@"
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
"@ > Dockerfile

Remove-Item -recurse -force base
New-Item -p base 

$env:DOCKER_BUILDKIT=1
docker build -f builder .
docker run --rm -it -v ${pwd}/base:/app  --user ${id -u}:${id -g} builder

Remove-Item Dockerfile
New-Item -p build/base



@"
# Ignore version control files:
.git/
.gitignore
.gitattributes

# Ignore docker and environment files:
Dockerfile*
docker-compose*.yml
.dockerignore
.env
.drone.yml
README.*
Makefile
"@ > .dockerignore

@"
# ignore enviroment files
.env
.bash_history

# Ignore bundler config.
/base/.bundle

# Ignore all logfiles and tempfiles.
/base/log/*
/base/tmp/*
!/base/log/.keep
!/base/tmp/.keep

# Ignore pidfiles, but keep the directory.
/base/tmp/pids/*
!/base/tmp/pids/
!/base/tmp/pids/.keep

/base/public/assets

# Ignore master key for decrypting credentials and more.
/base/config/master.key
"@ > .gitignore


