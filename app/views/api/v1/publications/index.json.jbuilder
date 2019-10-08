json.array! @publications do |publication|
  json.extract! publication, :id, :name
  json.authors publication.authors.uniq do |author|
    json.extract! author, :id, :full_name, :socials, :horoscope_count
  end
  json.horoscopes publication.horoscopes do |horoscope|
    json.extract! horoscope, :id, :author, :content, :zodiac_sign
  end
end

