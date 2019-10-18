require 'sidekiq-scheduler'

class FetchElleJob < ApplicationJob
  queue_as :default

  def perform
    Horoscope.fetch_elle_horoscopes
  end
end
