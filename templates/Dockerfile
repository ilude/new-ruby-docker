# syntax=docker/dockerfile:1.3-labs 
FROM ruby:3-alpine AS base

ARG BUNDLE_ARGS
ARG APP_USER=anvil

ENV APP=/app
ENV HOME=$APP
ENV RACK_ENV=production
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TZ=America/New_York

RUN apk --no-cache add \
  ca-certificates \
  curl \
#  freetds-dev \
  tzdata && \
  ln -snf /etc/localtime /usr/share/zoneinfo/$TZ && echo $TZ > /etc/timezone && \
  addgroup -S $APP_USER && \
  adduser -SDH -s /sbin/nologin -G $APP_USER $APP_USER && \
  echo "alias l='ls -lha --color=auto --group-directories-first'" >> /etc/profile.d/aliases.sh && \
  echo "PS1='\h:\$(pwd) \$ '" >> /etc/profile.d/prompt.sh && \
  rm -rf /var/cache/apk/* 

WORKDIR $APP

#COPY build/base/*-entrypoint.sh /usr/local/bin
COPY --chmod=755 <<-"EOF" /usr/local/bin/docker-entrypoint.sh
#!/bin/bash
set -e
# Remove pre-existing pid files
rm -f /app/tmp/pids/*.pid
exec $@
EOF

#RUN  chmod +x /usr/local/bin/*-entrypoint.sh 
  
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma"]

##############################
# Begin BUILD 
##############################
FROM base AS dev

RUN apk --no-cache add \
  bash \
  build-base \
  rm -rf /var/cache/apk/* 

COPY ./base/Gemfile ./base/Gemfile.lock $APP
RUN bundle install ${BUNDLE_ARGS} && \
    chown -R $APP_USER:$APP_USER /usr/local/bundle
ENV PATH="$APP/bin:${PATH}"


##############################
# Begin PROD 
##############################
FROM base AS prod

# copy gems from dev
COPY --from=dev /usr/local/bundle/ /usr/local/bundle/

COPY --chown=$APP_USER:$APP_USER ./base/ /app

USER $APP_USER
