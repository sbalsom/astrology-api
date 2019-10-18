require 'sidekiq-scheduler'

class FetchTeenVogueJob < ApplicationJob
  queue_as :default

  def perform(upper_limit)
    Horoscope.fetch_teen_vogue_horoscopes(upper_limit)
  end
end
