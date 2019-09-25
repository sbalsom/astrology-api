json.extract! @publication, :id, :name
json.horoscopes @publication.horoscopes do |horoscope|
  json.extract! horoscope, :id, :author, :content, :zodiac_sign
end
