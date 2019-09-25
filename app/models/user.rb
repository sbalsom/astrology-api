class User < ApplicationRecord
  has_many :user_zodiac_signs, dependent: :destroy
  has_many :zodiac_signs, through: :user_zodiac_signs
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
