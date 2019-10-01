require 'sidekiq'
require 'redis'

Sidekiq.configure_client do |config|
  config.redis = { url: 'http://localhost:3000' }
end

Sidekiq.configure_server do |config|
  config.redis = { url: 'http://localhost:3000' }
end
