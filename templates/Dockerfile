# syntax=docker/dockerfile:1.3-labs 
FROM ruby:3-alpine AS base

ARG APP_USER=anvil
ARG RAILS_ENV

ARG BUNDLE_WITH
ARG BUNDLE_WITHOUT
ARG BUNDLE_DEPLOYMENT

ENV BUNDLE_WITH=${BUNDLE_WITH}
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}
ENV BUNDLE_DEPLOYMENT=${BUNDLE_DEPLOYMENT}

ENV APP=/app
ENV HOME=$APP
ENV PATH="$APP/bin:${PATH}"
ENV RAILS_ENV=${RAILS_ENV}

ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TZ=America/New_York

RUN apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  tzdata && \
  ln -snf /etc/localtime /usr/share/zoneinfo/$TZ && echo $TZ > /etc/timezone && \
  addgroup -S $APP_USER && \
  adduser -SDH -s /sbin/nologin -G $APP_USER $APP_USER && \
  echo "alias l='ls -lha --color=auto --group-directories-first'" >> /etc/profile.d/aliases.sh && \
  echo "PS1='\h:\$(pwd) \$ '" >> /etc/profile.d/prompt.sh && \
  rm -rf /var/cache/apk/* 

WORKDIR $APP

COPY --chmod=755 <<-"EOF" /usr/local/bin/docker-entrypoint.sh
#!/bin/bash
set -e
if [ -v DOCKER_ENTRYPOINT_DEBUG ] && [ "$DOCKER_ENTRYPOINT_DEBUG" == 1 ]; then
  set -x
  set -o xtrace
fi

if [ "$RAILS_ENV" == "development" ]; 
then
    echo "Checking that bundled gems are upto date..."
    bundle check || bundle install;
fi

if [ -z ${RAILS_EMAIL_OVERRIDE} ] && [ "$RAILS_ENV" == "development" ]; then 
    echo "RAILS_EMAIL_OVERRIDE has not been set! Add RAILS_EMAIL_OVERRIDE=<your_email> to .env";
    exit 1; 
fi

echo "Running: $@"
exec $@
EOF

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma"]

##############################
# Begin BUILD 
##############################
FROM base AS dev

RUN apk --no-cache add \
  build-base \
  rm -rf /var/cache/apk/* 

COPY ./base/Gemfile* $APP
RUN bundle install 
COPY ./base/ /app

##############################
# Begin PROD 
##############################
FROM base AS prod

# copy gems from dev
COPY --from=dev /usr/local/bundle/ /usr/local/bundle/

COPY --chown=$APP_USER:$APP_USER ./base/ /app

ENV RAILS_ENV=production

USER $APP_USER
