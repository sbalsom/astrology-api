class Publication < ApplicationRecord
  has_many :horoscopes, dependent: :destroy
  has_many :authors, -> { distinct }, through: :horoscopes
  validates :name, presence: true, uniqueness: true

  scope :by_date, -> { order(created_at: :desc) }
end
