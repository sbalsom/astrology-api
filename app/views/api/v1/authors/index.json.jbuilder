json.array! @authors do |author|
  json.extract! author, :id, :full_name, :horoscope_count, :horoscopes, :socials, :publications
end


# json.authors publication.authors.uniq do |author|
  #   json.extract! author, :id, :full_name, :socials, :horoscope_count
  # end
  # json.horoscopes publication.horoscopes do |horoscope|
  #   json.extract! horoscope, :id, :author, :content, :zodiac_sign
  # end
