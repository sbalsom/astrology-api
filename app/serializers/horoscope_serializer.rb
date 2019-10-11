class HoroscopeSerializer < ActiveModel::Serializer
  attributes :id, :author, :publication, :content, :word_count, :start_date, :range_in_days, :zodiac_sign, :keywords, :mood, :original_link
end

