require 'sidekiq-scheduler'

class FetchAllureJob < ApplicationJob
  queue_as :default

  def perform
    Horoscope.fetch_allure_horoscopes
  end
end
