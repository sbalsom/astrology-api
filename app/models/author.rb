require 'pry-byebug'
require 'nokogiri'
require 'open-uri'

class Author < ApplicationRecord
  has_many :horoscopes, dependent: :destroy
  has_many :publications, through: :horoscopes
  validates :full_name, presence: true, uniqueness: true

  def handle_socials(doc, first_selector, publication, second_selector)
# grab the element from the DOM that has the link inside it
  # if !publication.authors.include?(self)
    byline = doc.at(first_selector)
    # get the href from this element
    unless byline&.attributes.nil?
      path = byline&.attributes['href'].value
      # navigate to this link
      html_file = open(publication.url + path).read
      html_doc = Nokogiri::HTML(html_file)
      links = html_doc.search(second_selector)
      links.each do |s|
        link = s&.attributes['href'].value
        socials << link unless socials.include?(link)
        save
      end
    end
  # end
end

def handle_simple_socials(selector, doc)
  s = doc.search(selector)
      s.each do |social|
        link = social&.attributes['href'].value
        socials << link unless socials.include?(link)
    end
end
end
