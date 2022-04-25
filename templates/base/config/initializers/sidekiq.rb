require 'sidekiq/api'
require 'sidekiq-status'
require 'sidekiq/web'
require 'sidekiq-status/web'

Sidekiq::Web.app_url = '/'

Sidekiq::Logging.logger.level = Logger.const_get( ENV.fetch("SIDEKIQ_LOG_LEVEL", "INFO") )

redis_url = "redis://#{ENV.fetch('REDIS_HOST', 'redis')}:#{ENV.fetch('REDIS_PORT', '6379')}/0"

Sidekiq.configure_server do |config|
  config.redis = {url: redis_url}

  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes

  config.server_middleware do |chain|
    chain.add AttentiveSidekiq::Middleware::Server::Attentionist
  end
end

Sidekiq.configure_client do |config|
  config.redis = {url: redis_url}
  
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end

# https://github.com/mperham/sidekiq/issues/2555
Sidekiq::Web.class_eval do
  disable :sessions
end
Sidekiq::Web.disable :sessions