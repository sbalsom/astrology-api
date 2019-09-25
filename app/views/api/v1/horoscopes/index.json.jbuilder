json.array! @horoscopes do |horoscope|
  json.extract! horoscope, :id, :author, :publication, :content
end
