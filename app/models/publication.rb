class Publication < ApplicationRecord
  has_many :horoscopes, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
