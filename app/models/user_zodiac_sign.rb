class UserZodiacSign < ApplicationRecord
  belongs_to :zodiac_sign
  belongs_to :user
  enum status: [:sun, :rising, :moon]
end
