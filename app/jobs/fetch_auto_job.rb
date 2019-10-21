# require 'sidekiq-scheduler'

class FetchAutoJob < ApplicationJob
  queue_as :default

  after_perform do |job|
    # invoke another job at your time of choice
    self.class.set(:wait => 1.week).perform_later
  end

  def perform
    Horoscope.fetch_autostraddle_horoscopes
  end
end
