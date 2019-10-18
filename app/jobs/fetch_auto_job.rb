require 'sidekiq-scheduler'

class FetchAutoJob < ApplicationJob
  queue_as :default

  def perform
    Horoscope.fetch_autostraddle_horoscopes
  end
end
