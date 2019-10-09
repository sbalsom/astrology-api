class HoroscopesSerializer < ActiveModel::Serializer
  attributes :id, :content, :range_in_days, :author, :start_date, :zodiac_sign, :keywords, :mood, :original_link, :word_count
end
