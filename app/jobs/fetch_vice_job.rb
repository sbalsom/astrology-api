# require 'sidekiq-scheduler'

class FetchViceJob < ApplicationJob
  queue_as :default

  after_perform do |job|
    # invoke another job at your time of choice
    self.class.set(:wait => 1.week).perform_later(job.arguments.first)
  end

  def perform(upper_limit)
    Horoscope.fetch_vice_horoscopes(upper_limit)
  end
end
