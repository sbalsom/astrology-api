class PublicationSerializer < ActiveModel::Serializer
  attributes :id, :name, :url

  has_many :authors, through: :horoscopes, uniq: true
end
