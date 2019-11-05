require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/cron/web'

Sidekiq.configure_server do |config|
  config.redis = { namespace:'Astrology-Api', url: (ENV["REDISCLOUD_URL"] ||'redis://127.0.0.1:6379/0') }

  config.on(:startup) do
    schedule_file = 'config/schedule.yml'
    if File.exists?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    end
  end
end


Sidekiq.configure_client do |config|
  config.redis = { namespace:'Astrology-Api', url: (ENV["REDISCLOUD_URL"] ||'redis://127.0.0.1:6379/0') }
end

