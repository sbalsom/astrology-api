# require 'sidekiq-scheduler'

class FetchMaskJob < ApplicationJob
  queue_as :default

  after_perform do |job|
    # invoke another job at your time of choice
    self.class.set(:wait => 1.week).perform_later(job.arguments.first)
  end

  def perform
    Horoscope.fetch_mask_horoscopes
  end
end
