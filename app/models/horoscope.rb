require 'nokogiri'
require 'open-uri'
require 'net/http'
require_relative 'scraper'
require 'net/http'
require 'json'

class Horoscope < ApplicationRecord
  belongs_to :publication
  belongs_to :author
  belongs_to :zodiac_sign

  validates :content, presence: true, uniqueness: true
  validates :original_link, presence: true

  scope :by_date, -> { order(start_date: :desc) }
  scope :min_words, ->(min_words) { where('word_count >= ?', min_words) }
  scope :range, ->(range) { where('range_in_days = ?', range) }
  scope :mood, ->(mood) { where('mood ILIKE ?', "#{mood}%") }

  def self.filter(params)
    horoscopes = Horoscope.all
    horoscopes = horoscopes.joins(:zodiac_sign).where('zodiac_signs.name' => params[:sign]) if params[:sign].present?
    horoscopes = horoscopes.joins(:publication).where('publications.name ILIKE ?', params[:publication]) if params[:publication].present?
    horoscopes = horoscopes.where(start_date: (params[:beg_date]..params[:end_date])) if params[:beg_date].present? && params[:end_date].present?
    horoscopes = horoscopes.mood(params[:mood]) if params[:mood].present?
    horoscopes = horoscopes.min_words(params[:min_words]) if params[:min_words].present?
    horoscopes = horoscopes.range(params[:range]) if params[:range].present?
    horoscopes
  end


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

  def self.fetch_vice_horoscopes(upper_limit) # upper limit max is 190
    vice = Publication.find_by(name: "Vice")
    scraper = ViceScraper.new(vice)
    scraper.start(upper_limit)
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

  def self.fetch_cosmo_horoscopes(upper_limit) # upper limit max is 70
    cosmo = Publication.find_by(name: "Cosmopolitan")
    scraper = CosmoScraper.new(cosmo)
    scraper.start(upper_limit)
  end

  def self.fetch_mask_horoscopes
    mask = Publication.find_by(name: "Mask Magazine")
    scraper = MaskScraper.new(mask)
    scraper.start
  end

  def self.fetch_cut_horoscopes(upper_limit) # upper limit max is 250 must increment by 50
    cut = Publication.find_by(name: "The Cut")
    scraper = CutScraper.new(cut)
    scraper.start(upper_limit)
  end

  def self.fetch_teen_vogue_horoscopes(upper_limit) # upper limit max is 10
    teen_vogue = Publication.find_by(name: "Teen Vogue")
    scraper = TeenVogueScraper.new(teen_vogue)
    scraper.start(upper_limit)
  end

  def self.fetch_refinery_horoscopes
    refinery = Publication.find_by(name: "Refinery 29")
    scraper = RefineryScraper.new(refinery)
    scraper.start
  end

end
