require 'pry-byebug'
require 'nokogiri'
require 'open-uri'

class Author < ApplicationRecord
  has_many :horoscopes, dependent: :destroy
  has_many :publications, through: :horoscopes
  validates :full_name, presence: true, uniqueness: true

  def handle_socials(doc, first_selector, publication, second_selector)
    scraper = Scraper.new(publication)
    byline = doc.at(first_selector)
    unless byline&.attributes.nil?
      path = byline&.attributes['href'].value
      second_doc = scraper.open_doc(publication.url + path)
      links = second_doc.search(second_selector)
      links.each do |s|
        link = s&.attributes['href'].value
        socials << link unless socials.include?(link)
        save
      end
    end
  end

  def handle_simple_socials(socials = [])
    socials.each do |social|
      socials << social unless socials.include?(social)
    end
  end

  def handle_one_step_socials(doc, selector)
    links = doc.search(selector)
    links.each do |s|
      link = s&.attributes['href'].value
      socials << link unless socials.include?(link)
      save
    end
  end
end
