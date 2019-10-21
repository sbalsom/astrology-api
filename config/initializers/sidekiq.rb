require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/cron/web'
# require 'sidekiq-scheduler'
# require 'sidekiq-scheduler/web'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    # SidekiqScheduler::Scheduler.instance.rufus_scheduler_options = { max_work_threads: 1 }
    # # Sidekiq.schedule = ConfigParser.parse(File.join(Rails.root, "config/sidekiq_scheduler.yml"), Rails.env)
    # SidekiqScheduler::Scheduler.instance.reload_schedule!
    schedule_file = 'config/schedule.yml'
    if File.exists?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    end
  end
end
