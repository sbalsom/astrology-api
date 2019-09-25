class Author < ApplicationRecord
  has_many :horoscopes, dependent: :destroy
  validates :full_name, presence: true, uniqueness: true
end
