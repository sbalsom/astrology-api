require 'sidekiq-scheduler'

class FetchViceJob < ApplicationJob
  queue_as :default

  def perform(upper_limit)
    Horoscope.fetch_vice_horoscopes(upper_limit)
  end
end
