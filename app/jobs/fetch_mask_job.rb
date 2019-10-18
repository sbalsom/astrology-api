require 'sidekiq-scheduler'

class FetchMaskJob < ApplicationJob
  queue_as :default

  def perform
    Horoscope.fetch_mask_horoscopes
  end
end
