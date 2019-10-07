require 'nokogiri'
require 'open-uri'
require 'pry-byebug'
require 'net/http'
require 'watir'
require_relative 'scraper'
require 'net/http'
require 'json'

class Horoscope < ApplicationRecord
  belongs_to :publication
  belongs_to :author
  belongs_to :zodiac_sign

  validates :content, presence: true, uniqueness: true
  validates :original_link, presence: true
  # adds keywords to any horoscope

  def handle_keywords
    kw = [
      "venus",
      "mars",
      "mercury",
      "saturn",
      "jupiter",
      "uranus",
      "neptune",
      "pluto",
      "north node",
      "south node",
      "lillix",
      "new moon",
      "full moon",
      "eclipse",
      "trine",
      "square",
      "conjunct",
      "moon",
      "sun",
      "sextile",
      "opposition"
    ]
    matches = content&.downcase&.scan(Regexp.union(kw))
    matches&.each do |match|
      keywords << match unless keywords.include?(match)
    end
    save
  end

  def monthly?
    range_in_days == 30
  end

  def weekly?
    range_in_days == 7
  end

  def daily?
    range_in_days == 1
  end


  def self.fetch_vice_horoscopes
    vice = Publication.find_by(name: "Vice")
    scraper = ViceScraper.new(vice)
    scraper.start
  end

  def self.fetch_allure_horoscopes
    allure = Publication.find_by(name: "Allure")
    scraper = AllureScraper.new(allure)
    scraper.start
  end

  def self.fetch_autostraddle_horoscopes
    autostraddle = Publication.find_by(name: "Autostraddle")
    scraper = AutoScraper.new(autostraddle)
    scraper.start
  end

  def self.fetch_elle_horoscopes
    @elle = Publication.find_by(name: "Elle")
    scraper = ElleScraper.new(@elle)
    scraper.start
  end

  def self.fetch_cosmo_horoscopes
    cosmo = Publication.find_by(name: "Cosmopolitan")
    scraper = CosmoScraper.new(cosmo)
    scraper.start
  end

  def self.fetch_mask_horoscopes
    mask = Publication.find_by(name: "Mask Magazine")
    scraper = MaskScraper.new(mask)
    scraper.start
  end

  def self.fetch_cut_horoscopes
    cut = Publication.find_by(name: "The Cut")
    scraper = CutScraper.new(cut)
    scraper.start
  end

  def self.fetch_teen_vogue_horoscopes
    teen_vogue = Publication.find_by(name: "Teen Vogue")
    scraper = TeenVogueScraper.new(teen_vogue)
    scraper.start
  end

  def self.fetch_refinery_horoscopes
    refinery = Publication.find_by(name: "Refinery 29")
    scraper = RefineryScraper.new(refinery)
    scraper.start
  end

end

# I want to add to my database :

# jessica lanyadoo (offset pagination hard to scrape ?)
# astrology zone - current month and current year only for every sign - easy !
# cafe astrology - there is a lot going on here -- maybe come back to this
# channi nicholas --
# refinery 29


# an api view for authors
# more keywords for each horoscope (emotions, other)
# handling method for 2015 monthlies

# more associations : author has many publications, through horoscopes


# Vice : 190 pages total going back to 2015

