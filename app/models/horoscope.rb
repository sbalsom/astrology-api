require 'nokogiri'
require 'open-uri'
require 'pry-byebug'

class Horoscope < ApplicationRecord
  belongs_to :publication
  belongs_to :author
  belongs_to :zodiac_sign

  # global methods

  def self.handle_author(author)
    if author == "Annabel Get"
      author = "Annabel Gat"
    end
    if Author.where(full_name: author).empty?
      puts "creating author #{author}"
      author = Author.create(full_name: author)
    else
      puts "referencing author #{author}"
      author = Author.find_by(full_name: author)
    end
    author
  end

  def self.handle_keywords(horoscope)
    keywords = [
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
      "sun"
    ]
    text = horoscope.content
    regex = /#{Regexp.union(keywords)}/
    matches = text.downcase.scan(regex)
    horoscope.keywords = matches
    horoscope.save
  end

  def self.compile_links(base_url, selector, query = '')
    links = []
    html_file = open(base_url + query.to_s).read
    html_doc = Nokogiri::HTML(html_file)
    html_doc.search(selector).each do |element|
      a = element.attribute('href').value
      links << a
    end
    links
  end

  # vice methods

  def self.fetch_vice_horoscopes
    # should I create the vice instance in the seed file ? right now it is there
    @vice = Publication.find_by(name: "Vice")
    base_url = 'https://www.vice.com'
    main_path = '/en_us/topic/horoscopes?page='
    b = base_url + main_path
    vice_links = []
    i = 1
    # while i <= 190 do
    while i <= 10 do
      vice_links += compile_links(b, 'a.grid__wrapper__card', i)
      i += 1
    end
    # this could be factored into its own method for brevity
    vice_links.each do |link|
      html_file = open(base_url + link).read
      html_doc = Nokogiri::HTML(html_file)
      raw_author = html_doc.at("meta[property='article:author']").attributes['content'].value
      raw_content = html_doc.search('.article__body').text.strip
      raw_title = html_doc.at("title").text
      raw_date = Time.parse(html_doc.at("meta[name='datePublished']").attributes['content'].value)
      range = raw_title.scan(/(Daily|Weekly|^Monthly)/).flatten
      social_path = html_doc.at(".contributor__link").attributes['href'].value
      if range[0] == "Daily"
        # sometimes makes horoscopes out of headings
        #returned a horoscope with no content ??
        author = handle_author(raw_author)
        handle_vice_social(base_url, social_path, author)
        content = raw_content
        interval = 1
        date = raw_date + 1.days
        create_vice_horoscope(content, interval, author, date)
      elsif range[0] == "Weekly"
        author = handle_author(raw_author)
        handle_vice_social(base_url, social_path, author)
        content = raw_content
        interval = 7
        date = raw_date
        create_vice_horoscope(content, interval, author, date)
      elsif range[0] == "Monthly"
        zodiac_signs = ZodiacSign.all.map { |sign| sign.name }
        sign = raw_title.scan(Regexp.union(zodiac_signs))
        zodiac = ZodiacSign.find_by(name: sign)
        content = raw_content.sub("Download the Astro Guide app by VICE on an iOS device to read daily horoscopes personalized for your sun, moon, and rising signs, and learn how to apply cosmic events to self care, your friendships, and relationships.", '')
        author = handle_author(raw_author)
        date = raw_date
        handle_vice_social(base_url, social_path, author)
        handle_vice_monthlies(content, author, zodiac, date)
      end
    end
    Horoscope.all
  end

  def self.handle_vice_social(base_url, path, author)
    html_file = open(base_url + path).read
    html_doc = Nokogiri::HTML(html_file)
    socials = html_doc.search(".contributor__profile__bio a")
    socials.each do |s|
      link = s.attributes['href'].value
      author.socials << link unless author.socials.include?(link)
      author.save
    end
  end

  def self.handle_vice_monthlies(content, author, zodiac, date)
    if Horoscope.where(content: content).empty?
      h = Horoscope.create!(
        content: content,
        author: author,
        zodiac_sign: zodiac,
        publication: @vice,
        range_in_days: 30,
        start_date: date
      )
      author.horoscope_count += 1
      author.save
      handle_keywords(h)
    end
  end

  def self.create_vice_horoscope(content, interval, author, date)
    stopwords = ZodiacSign.all.map { |sign| sign.name }
    stopwords_regex = /(Aries\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Taurus\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Gemini\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Cancer\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Leo\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Virgo\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Libra\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Scorpio\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Sagittarius\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Capricorn\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Aquarius\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Pisces\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\))/
    text = content.split(stopwords_regex).collect(&:strip).reject(&:empty?)
    stopwords.each do |s|
      matcher = /^#{s}\s\(\w+\s\d{2}\s-\s\w+\s\d{2}/
      text.each_with_index do |word, index|
        # matcher = Regexp.new(m)
        next if word !~ matcher
        kontent = text[index + 1]
        if Horoscope.where(content: kontent).empty?
          zodiac = ZodiacSign.find_by(name: s)
          h = Horoscope.create!(
            zodiac_sign: zodiac,
            content: kontent,
            author: author,
            range_in_days: interval,
            start_date: date,
            publication: @vice
          )
          author.horoscope_count += 1
          author.save
          handle_keywords(h)
        end
      end
    end
  end

  # allure methods
  def self.fetch_allure_horoscopes
    @allure = Publication.find_by(name: "Allure")
    base_url = 'https://www.allure.com/topic/monthly-horoscope'
    selector = '.feature-item-link'
    allure_links = compile_links(base_url, selector)
  end

  # end of the class
end

# I want to add to my database :

# total horoscopes written by each author
# an api view for authors
# more keywords for each horoscope (emotions, other)
# handling method for 2015 monthlies

# more associations : author has many publications, through horoscopes

# Vice : 190 pages total going back to 2015

#Allure horoscopes : need a way to get page with javascript
