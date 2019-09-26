class Author < ApplicationRecord
  has_many :horoscopes, dependent: :destroy
  has_many :publications, through: :horoscopes
  validates :full_name, presence: true, uniqueness: true
end
