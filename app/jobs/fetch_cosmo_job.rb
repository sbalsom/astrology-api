require 'sidekiq-scheduler'

class FetchCosmoJob < ApplicationJob
  queue_as :default

  def perform(upper_limit)
    Horoscope.fetch_cosmo_horoscopes(upper_limit)
  end
end
