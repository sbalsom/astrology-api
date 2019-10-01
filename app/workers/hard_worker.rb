class HardWorker
  include Sidekiq::Worker

  def perform(first_page, last_page)
    # Horoscope.fetch_vice_horoscopes(first_page, last_page)
    puts "first argument #{first_page}"
    sleep 5
    puts "second argument #{last_page}"
  end
end
