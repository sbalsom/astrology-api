class AuthorSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :socials, :horoscope_count

  has_many :publications, through: :horoscopes, uniq: true
end
