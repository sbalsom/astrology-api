require 'nokogiri'
require 'open-uri'
require 'pry-byebug'
require 'net/http'
require 'watir'
require_relative 'scraper'

class Horoscope < ApplicationRecord
  belongs_to :publication
  belongs_to :author
  belongs_to :zodiac_sign

  validates :content, presence: true, uniqueness: true

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
    @vice = Publication.find_by(name: "Vice")
    scraper = ViceScraper.new(@vice)
    main_path = '/en_us/topic/horoscopes?page='
    url = @vice.url + main_path
    links = []
    i = 1
    while i <= 3
      puts "compiling"
      links += scraper.compile_links(url, 'a.topics-card__heading-link', i)
      i += 1
    end
    scraper.scrape(links)
  end

  def self.fetch_allure_horoscopes
    @allure = Publication.find_by(name: "Allure")
    scraper = AllureScraper.new(@allure)
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
    @autostraddle = Publication.find_by(name: "Autostraddle")
    scraper = AutoScraper.new(@autostraddle)
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

#  cosmo methods still needs refactoring

  def self.fetch_cosmo_horoscopes
    @cosmo = Publication.find_by(name: "Cosmopolitan")
    scraper = CosmoScraper.new(@cosmo)
    cosmo_links = []
    selector = ".full-item-title"
    i = 1
    while i <= 70
      cosmo_infinite_url = "https://www.cosmopolitan.com/ajax/infiniteload/?id=62fa165c-d912-4e6f-9b34-c215d4f288e2&class=CoreModels%5Ccollections%5CCollectionModel&viewset=collection&page=#{i}&cachebuster=362ce01c-9ff7-4b0a-bb8e-00fdbd99f3cd"
      # cosmo_links_links += compile_links(cosmo_infinite_url, selector)
      html_file = open(cosmo_infinite_url).read
      html_doc = Nokogiri::HTML(html_file)
      html_doc.search(selector).each do |element|
        a = element.attributes['href'].value
        cosmo_links << a
      end
      puts i
      i += 1
    end
    zodiac_regex = /(horoscope|horoscopes|weekly|monthly|daily|week)/
    @cosmo_links = cosmo_links.reject do |l|
      zodiac_regex.match(l).nil?
    end
    @cosmo_links.each do |path|
      scraper.scrape(path)
    end
  end
# still needs refactoring

  def self.fetch_mask_horoscopes
    @mask = Publication.find_by(name: "Mask Magazine")
    scraper = Scraper.new(@mask)

    url = 'http://www.maskmagazine.com/contributors/corina-dross'
    file = open(url).read
    doc = Nokogiri::HTML(file)
    raw_author = "Corina Dross"
    author = handle_author(raw_author)
    selector = '.published-work a'
    links = doc.search(selector)
    paths = links.map {|l| l&.attributes['href'].value }
    paths.each_with_index do |path, index|
      match = path.scan(/\w+-\d{4}/)&.first
      date = Time.now
      match.nil? ? date = Time.now : date = Time&.parse(match)
      # date = Time.parse(links[index].text)
      url = @mask.url + path
      hash = scraper.visit_links(url, '.body')
      hash.each do |sign, content|
        zodiac = ZodiacSign.find_by(name: sign)
        build_horoscope(content, zodiac, author, 30, date, @mask, url)
      end
    end
  end



end


# I want to add to my database :

# an api view for authors
# more keywords for each horoscope (emotions, other)
# handling method for 2015 monthlies
# make sure that the keywords are unique

# more associations : author has many publications, through horoscopes

# ideally this should all belong to a class called scraper that can be modified depending on the publication
# Scraper.new(publication, base_url) would call the class scraper
#  oh well maybe that's for another version


# Vice : 190 pages total going back to 2015


# def self.compile_links(base_url, selector, query = '')
  #   links = []
  #   html_file = open(base_url + query.to_s).read
  #   html_doc = Nokogiri::HTML(html_file)
  #   html_doc.search(selector).each do |element|
  #     a = element.attributes['href'].value
  #     links << a
  #   end
  #   links
  # end

    # def self.visit_links(url, selector)
  #   file = open(url).read
  #   doc = Nokogiri::HTML(file)
  #   text = doc.search(selector)
  #   auto_zip(text)
  # end


  # def self.auto_zip(text)
  #   text.to_enum.map(&:text)
  #   t = text.children.map { |x| x.text.strip }
  #   t = t.reject { |x| x == "" }
  #   t = t.join('~*~')
  #   signs = t.scan(/~\*~\w{3,20}~\*~/)
  #   horoscopes = t.split(/~\*~\w{3,20}~\*~/).pop(12)
  #   h = horoscopes.map {|x| x.gsub(/~\*~/, '')}
  #   signs = signs.map {|s| s.gsub(/~\*~/, '')}
  #   Hash[signs.zip(h)]
  # end


  # def self.auto_scraper(links)
  #   links.each do |link|
  #     puts link
  #     file = open(link)
  #     doc = Nokogiri::HTML(file)
  #     text = doc.search('.entry-content')
  #     # author not working
  #     raw_author = doc.at("a[rel='author']").text
  #     author = handle_author(raw_author)
  #     date = Time.parse(doc.at('time').text)
  #     # this part will be refactored into own class ?
  #     hash = scraper.auto_zip(text)
  #     hash.each do |sign, content|
  #       zodiac = ZodiacSign.find_by(name: sign)
  #       build_horoscope(content, zodiac, author, 7, date, @autostraddle, link)
  #     end
  #     # could be its own method
  #   # author.handle_simple_socials('.sd-content a', doc)
  #   end
  # end
  # this is probably the simplest method ive come up with ! use it for the others ?

# retrieves the author from the database
#   def self.handle_author(author)
#     if author == "Annabel Get"
#       author = "Annabel Gat"
#     elsif author == "The AstroTwinsThe AstroTwins"
#       author = "Tali and Ophira Edut"
#     elsif author == "Aliza Kelly Faragher"
#       author = "Aliza Kelly"
#     elsif author == "Corina"
#       author = "Corina Dross"
#     end
#     if Author.where(full_name: author).empty?
#       puts "creating author #{author}"
#       author = Author.create(full_name: author)
#     else
#       puts "referencing author #{author}"
#       author = Author.find_by(full_name: author)
#     end
#     author
#   end

# def self.vice_scraper(vice_links, doc)
  #   vice_links.each do |link|

  #     #  grabs raw elements from the DOM
  #     raw_author = doc.at(".contributor__link")&.text
  #     raw_author = "Unknown" if raw_author.nil?

  #     date_published = Time.parse(doc.at("meta[name='datePublished']").attributes['content'].value)
  #     raw_content = doc.search('.article__body')
  #     title = doc.at("title").text

  #     # checks the title to see which kind of horoscope it is for handling
  #     range = title.scan(/(Daily|Weekly|^Monthly)/).flatten
  #     type = range[0]
  #     # sets interval in days for each type of horoscope
  #     interval = interval(type)
  #     # could return an object {range_in_days: interval, }

  #     # this could be another method

  #     unless /Daily|Weekly/.match(range[0]).nil?
  #       author = handle_author(raw_author)
  #       range[0] == "Daily" ? date = date_published + 1.days : date = date_published
  #       horoscope_hash = horoscope_zip(raw_content)
  #       horoscope_hash.each do |sign, content|
  #         zodiac = ZodiacSign.find_by(name: sign)
  #         build_horoscope(content, zodiac, author, interval, date, @vice, link)
  #       end
  #     end
  #     #  monthlies are handled separately bc they are separate articles
  #     if range[0] == "Monthly"
  #       author = handle_author(raw_author)
  #       sign = title.scan(@@zodiac_regex)
  #       zodiac = ZodiacSign.find_by(name: sign)
  #       content = raw_content.text.strip.sub(@@advertising_regex, '')
  #       build_horoscope(content, zodiac, author, 30, date_published, @vice, link)
  #     end
  #     #  only do this if author is new and variable exists (is a horoscope author)
  #     if author
  #       author.handle_socials(doc, ".contributor__link", @vice, ".contributor__profile__bio a")
  #     end
  #   end
  # end

    # def self.interval(string)
  #   return 1 if string == "Daily"
  #   return 7 if string == "Weekly"
  #   return 30 if string == "Monthly"
  # end



  # builds horoscope
  # def self.horoscope_zip(raw_content)
  #   stopwords_regex = /\+(Aries(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Taurus(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Gemini(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Cancer(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Leo(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Virgo(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Libra(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Scorpio(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Sagittarius(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Capricorn(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Aquarius(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Pisces(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?)\+/
  #   headers = raw_content.search('h2')
  #   paragraphs = raw_content.search('p')
  #   array = paragraphs.to_enum.map {|child| child.text.strip.gsub(@@advertising_regex, "")}
  #   a = array.reject { |el| el.length < 42 }
  #   a = a.pop(12)
  #   h = headers.map { |header| header.text[@@zodiac_regex] }
  #   h = h.compact
  #   Hash[h.zip(a)]
  # end

  # vice methods



  # sets up a handy zodiac regex and array
  # @@zodiac_signs = ZodiacSign.all.map { |sign| sign.name }
  # @@zodiac_regex = Regexp.union(@@zodiac_signs)
  # @@downcase_zodiac = ZodiacSign.all.map { |sign| sign.name.downcase }
  # @@downcase_z_regex = Regexp.union(@@downcase_zodiac)
  # ADVERTISING_PHRASES = [
  #   "Download the Astro Guide app by VICE on an iOS device",
  #   "to read daily horoscopes personalized for your sun, moon, and rising signs,",
  #   "and learn how to apply cosmic events to self care, your friendships, and relationships.",
  #   "Read your monthly horoscope here.",
  #   "Want these horoscopes sent straight to your inbox?",
  #   "Click here to sign up for the newsletter.",
  #   "What's in the stars for you in",
  #   "Read more stories about astrology:",
  #   "These are the signs you're most compatible with romantically:"
  # ]
  # @@advertising_regex = Regexp.union(ADVERTISING_PHRASES)

