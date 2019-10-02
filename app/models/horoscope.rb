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

  validates :content, presence: true, uniqueness: true, length: { minimum: 100 }

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

  def self.fetch_vice_horoscopes
    vice = Publication.find_by(name: "Vice")
    scraper = ViceScraper.new(vice)
    main_path = '/en_us/topic/horoscopes?page='
    url = vice.url + main_path
    links = []
    i = 1
    #  check before final push to make sure all 190 pages are working
    while i <= 190
      puts "compiling"
      links += scraper.compile_links(url, 'a.topics-card__heading-link', i)
      i += 1
    end
    scraper.scrape(links)
  end

  def self.fetch_allure_horoscopes
    allure = Publication.find_by(name: "Allure")
    scraper = AllureScraper.new(allure)
    allure_links = scraper.compile_links
    allure_links.each do |link|
      begin
        doc = scraper.open_doc(link)
        scraper.scrape(doc, link)
      rescue OpenURI::HTTPError => e
        next if e.message == '404 Not Found'
      end
    end
  end

  def self.fetch_autostraddle_horoscopes
    autostraddle = Publication.find_by(name: "Autostraddle")
    scraper = AutoScraper.new(autostraddle)
    selector = ".entry-title a"
    i = 1
    auto_links = []
    while i <= 3
      topic_url = "https://www.autostraddle.com/tag/queer-horoscopes/page/#{i}/"
      auto_links += scraper.compile_links(topic_url, selector)
      puts i
      i += 1
    end
    auto_links = auto_links.select { |link| /queer-horoscopes/.match(link) }
    scraper.scrape(auto_links)
  end

  def self.fetch_elle_horoscopes
    @elle = Publication.find_by(name: "Elle")
    scraper = ElleScraper.new(@elle)
    paths = [
      "/horoscopes/daily/",
      "/horoscopes/weekly/",
      "/horoscopes/monthly/"
    ]
    selector = '.simple-item-title'
    elle_paths = []
    paths.each do |p|
      url = @elle.url + p
      elle_paths += scraper.compile_links(url, selector)
    end
    elle_paths.each do |path|
      scraper.scrape(path)
    end
  end

  def self.fetch_cosmo_horoscopes
    cosmo = Publication.find_by(name: "Cosmopolitan")
    scraper = CosmoScraper.new(cosmo)
    cosmo_links = []
    i = 1
    while i <= 70
      selector = ".full-item-title"
      cosmo_infinite_url = "https://www.cosmopolitan.com/ajax/infiniteload/?id=62fa165c-d912-4e6f-9b34-c215d4f288e2&class=CoreModels%5Ccollections%5CCollectionModel&viewset=collection&page=#{i}&cachebuster=362ce01c-9ff7-4b0a-bb8e-00fdbd99f3cd"
      cosmo_links += scraper.compile_links(cosmo_infinite_url, selector)
      i += 1
    end
    title_regex = /(horoscope|horoscopes|weekly|monthly|daily|week)/
    cosmo_links = cosmo_links.reject { |l| title_regex.match(l).nil? }
    cosmo_links.each_with_index do |path, index|
      puts "#{index}/#{cosmo_links.length}"
      scraper.scrape(path)
    end
  end

  def self.fetch_mask_horoscopes
    mask = Publication.find_by(name: "Mask Magazine")
    scraper = MaskScraper.new(mask)
    initial_url = 'http://www.maskmagazine.com/contributors/corina-dross'
    selector = '.published-work a'
    paths = scraper.compile_links(initial_url, selector)
    paths = paths.select { |p| /\d{4}/.match(p) }
    paths.each do |path|
      scraper.scrape(path)
    end
  end

  def self.fetch_cut_horoscopes
    cut = Publication.find_by(name: "The Cut")
    scraper = CutScraper.new(cut)
    links = []
    selector = '.main-article-content a'
    i = 0
    while i <= 250
      url = "https://www.thecut.com/tags/astrology/?start=#{i}"
      links += scraper.compile_links(url, selector)
      i += 50
    end
    links.each do |link|
      scraper.scrape(link)
    end
  end

  def self.fetch_teen_vogue_horoscopes
    teen_vogue = Publication.find_by(name: "Teen Vogue")
    scraper = TeenVogueScraper.new(teen_vogue)
    i = 1
    while i < 10
      url = "https://www.teenvogue.com/api/search?page=#{i}&size=10&sort=publishDate%20desc&types=%22article%22%2C%22gallery%22&categoryIds=%225a4d5863aed9070f9ecfbf4a%22&tags=%22weekly%20horoscopes%22"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      results = JSON.parse(response)
      hits = results['hits']['hits']
      hits.each do |hit|
        scraper.api_scrape(hit)
      end
    i += 1
    end
  end


end

# I want to add to my database :

# jessica lanyadoo (offset pagination hard to scrape ?)
# teen vogue weekly
# astrology zone
# cafe astrology
# channi nicholas
# refinery 29

# an api view for authors
# more keywords for each horoscope (emotions, other)
# handling method for 2015 monthlies

# more associations : author has many publications, through horoscopes


# Vice : 190 pages total going back to 2015

