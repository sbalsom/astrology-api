class Publication < ApplicationRecord
  has_many :horoscopes, dependent: :destroy
  has_many :authors, through: :horoscopes
  validates :name, presence: true, uniqueness: true
end
