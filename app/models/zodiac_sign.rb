class ZodiacSign < ApplicationRecord
  has_many :horoscopes
  validates :name, presence: true, uniqueness: true
end
