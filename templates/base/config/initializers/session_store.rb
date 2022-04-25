
# Use Redis as the session store:
Rails.application.config.session_store :redis_session_store, 
  key: "_#{ENV.fetch('APP_NAME', 'app')}_session",
  redis: {
    expire_after: 120.minutes,
    key_prefix: "#{ENV.fetch('APP_NAME', 'app')}:session:",
    url: "redis://#{ENV.fetch('REDIS_HOST', 'redis')}:#{ENV.fetch('REDIS_PORT', '6379')}/data/session"
  }
