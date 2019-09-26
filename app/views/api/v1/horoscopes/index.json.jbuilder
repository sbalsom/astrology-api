json.array! @horoscopes do |horoscope|
  json.extract! horoscope, :id, :author, :publication, :content, :zodiac_sign, :start_date, :range_in_days
end
