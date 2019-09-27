require 'nokogiri'
require 'open-uri'
# require 'watir'
require 'pry-byebug'
require 'net/http'

# ideally this should all belong to a class called scraper that can be modified depending on the publication
# Scraper.new(publication, base_url) would call the class scraper
#  oh well maybe that's for another version

class Horoscope < ApplicationRecord
  belongs_to :publication
  belongs_to :author
  belongs_to :zodiac_sign

  # classwide methods and variables

  # sets up a handy zodiac regex and array
  @@zodiac_signs = ZodiacSign.all.map { |sign| sign.name }
  @@zodiac_regex = Regexp.union(@@zodiac_signs)

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
    matches.each do |match|
      horoscope.keywords << match unless horoscope.keywords.include?(match)
    end
    horoscope.save
  end

  def self.compile_links(base_url, selector, query)
    links = []
    html_file = open(base_url + query.to_s).read
    html_doc = Nokogiri::HTML(html_file)
    html_doc.search(selector).each do |element|
      a = element.attributes['href'].value
      links << a
    end
    links
  end

  def self.handle_socials(base_url, path, selector, author)
    html_file = open(base_url + path).read
    html_doc = Nokogiri::HTML(html_file)
    socials = html_doc.search(selector)
    socials.each do |s|
      unless s.nil?
        link = s.attributes['href'].value
        author.socials << link unless author.socials.include?(link)
        author.save
      end
    end
  end

  # vice methods

  def self.fetch_vice_horoscopes
    # should I create the vice instance in the seed file ? right now it is there
    @vice = Publication.find_by(name: "Vice")
    @vice_base_url = 'https://www.vice.com'
    main_path = '/en_us/topic/horoscopes?page='
    b = @vice_base_url + main_path
    vice_links = []
    i = 48
    # compiling links to be scraped
    while i <= 49 do
      vice_links += compile_links(b, 'a.topics-card__heading-link', i)
      i += 1
    end
    puts vice_links
    vice_scraper(vice_links)
    Horoscope.all
  end

  def self.vice_scraper(vice_links)
    vice_links.each do |link|
      html_file = open(link).read
      html_doc = Nokogiri::HTML(html_file)

      #  grabs raw elements from the DOM
      raw_author = html_doc.at("meta[property='article:author']").attributes['content'].value
      date_published = Time.parse(html_doc.at("meta[name='datePublished']").attributes['content'].value)
      raw_content = html_doc.search('.article__body')
      title = html_doc.at("title").text

      # finds the author in the db
      author = handle_author(raw_author)

      # gets social links for handling socials
      s = html_doc.at(".contributor__link")
      # only adds social links if the author doesn't already exist and the path leads to author page
      if s.attributes['title'] == raw_author && !@vice.authors.include?(author)
        social_path = s.attributes['href'].value
        social_selector = ".contributor__profile__bio a"
        handle_socials(@vice_base_url, social_path, social_selector, author)
      end

      # checks the title to see which kind of horoscope it is for handling
      range = title.scan(/(Daily|Weekly|^Monthly)/).flatten
      type = range[0]
      # sets interval in days for each type of horoscope
      interval = set_interval(type)
      p interval
      # this is nil whoops

      # zips dailies and weeklies into a hash
      unless /Daily|Weekly/.match(range[0]).nil?
        horoscope_hash = horoscope_zip(raw_content)
        range[0] == "Daily" ? date = date_published + 1.days : date = date_published
        create_vice_horoscope(horoscope_hash, author, interval, date)
      end

      #  monthlies are handled separately bc they are separate articles
      if range[0] == "Monthly"
        # zodiac_signs = ZodiacSign.all.map { |sign| sign.name }
        sign = title.scan(@@zodiac_regex)
        zodiac = ZodiacSign.find_by(name: sign)
        binding.pry
        content = raw_content.text.strip.sub("Download the Astro Guide app by VICE on an iOS device to read daily horoscopes personalized for your sun, moon, and rising signs, and learn how to apply cosmic events to self care, your friendships, and relationships.", '')
        date = raw_date
        handle_vice_monthlies(content, author, zodiac, date)
      end

      # older horoscopes have different formatting (~past page 48)
      if date_published <= Time.parse("2018-10-12 00:00:00")
        # should handle older ones differently, come back to this and change the date...
      end
    end
  end

  def self.set_interval(type)
    return 1 if type == "Daily"
    return 7 if type == "Weekly"
    return 30 if type == "Monthly"
  end

  def self.create_vice_horoscope(horoscope_hash, author, interval, date)
    horoscope_hash.each do |sign, content|
      if Horoscope.where(content: content).empty?
        zodiac = ZodiacSign.find_by(name: sign)
        h = Horoscope.create!(
          zodiac_sign: zodiac,
          content: content,
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

  def self.horoscope_zip(raw_content)
    headers = raw_content.search('h2')
    headers = headers.map { |header| header.text[@@zodiac_regex] }
    array = []
    horoscopes = []
    raw_content.children.each do |node|
      if node.name == "h2"
        array << node
      elsif node.name == "p"
        array << node
      end

    end
    binding.pry
    array.each_with_index do |node, index|
      if array[index-1].name == 'h2'
        horoscopes << node
      end
    end
    text = horoscopes.map {|t| t.text}
    binding.pry
    Hash[headers.zip(text)]
  end

  def self.handle_old_dailies(content_hash, interval, author, date)
    puts "handling....."
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

  # allure methods

  def self.fetch_allure_horoscopes
    @allure = Publication.find_by(name: "Allure")
    allure_links = compile_allure_links
    allure_links.each do |link|
      begin
        file = open(link)
        doc = Nokogiri::HTML(file)
        allure_scrape(doc, link)
      rescue OpenURI::HTTPError => e
        next if e.message == '404 Not Found'
      end
    end
    # end
  end

  def self.compile_allure_links
    links = []
    year = Time.now.year
    months = Date::MONTHNAMES.slice(1, 12).map { |x| x.downcase }
    zodiac = ZodiacSign.all.map { |s| s.name.downcase }
    months.each do |month|
      zodiac.each do |sign|
        links << "https://www.allure.com/story/#{sign}-horoscope-#{month}-#{year}"
      end
    end
    links
  end

  def self.allure_scrape(doc, link)
    raw_author = doc.search('.byline__name-link').text
    author = handle_author(raw_author)
    lede = doc.search('.content-header__dek').text
    body_paragraphs = doc.search('.article__body p')
    body_paragraphs.shift
    body_paragraphs.pop
    b = body_paragraphs.text.gsub(/(Read more stories about astrology:|These are the signs you're most compatible with romantically:)/, '')
    content = "#{lede} #{b}"
    # zodiac_signs = ZodiacSign.all.map { |sign| sign.name.downcase }
    months = Date::MONTHNAMES.slice(1, 12).map { |x| x.downcase }
    raw_sign = link.scan(@@zodiac_regex)
    r = raw_sign[0].capitalize
    sign = ZodiacSign.find_by(name: r)
    month = link.scan(Regexp.union(months))
    year = link.scan(/\d{4}/)
    date = DateTime.parse("1 #{month} #{year}")
    if Horoscope.where(content: content).empty?
     h = Horoscope.create(
      zodiac_sign: sign,
      content: content,
      author: author,
      range_in_days: 30,
      start_date: date,
      publication: @allure
      )
      puts h
      author.horoscope_count += 1
      author.save
      handle_keywords(h)
      @allure_base_url = 'https://www.allure.com'
      social_path = doc.at(".byline__name-link").attributes['href'].value
      selector = '.social-links a'
      handle_socials(@allure_base_url, social_path, selector, author)
    end
  end


end

# I want to add to my database :

# an api view for authors
# more keywords for each horoscope (emotions, other)
# handling method for 2015 monthlies
# make sure that the keywords are unique

# more associations : author has many publications, through horoscopes

# Vice : 190 pages total going back to 2015


#  i might need this code if i cant get the zip to work

  # def self.create_vice_horoscope(content, interval, author, date)
  #   stopwords = ZodiacSign.all.map { |sign| sign.name }
  #   stopwords_regex = /(Aries\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Taurus\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Gemini\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Cancer\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Leo\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Virgo\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Libra\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Scorpio\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Sagittarius\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Capricorn\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Aquarius\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Pisces\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\))/
  #   text = content.split(stopwords_regex).collect(&:strip).reject(&:empty?)
  #   stopwords.each do |s|
  #     matcher = /^#{s}\s\(\w+\s\d{2}\s-\s\w+\s\d{2}/
  #     text.each_with_index do |word, index|
  #       next if word !~ matcher
  #       kontent = text[index + 1].gsub(/(Read your monthly horoscope here.|Want these horoscopes sent straight to your inbox?|Click here to sign up for the newsletter.)/, '')
  #       if Horoscope.where(content: kontent).empty?
  #         zodiac = ZodiacSign.find_by(name: s)
  #         h = Horoscope.create!(
  #           zodiac_sign: zodiac,
  #           content: kontent,
  #           author: author,
  #           range_in_days: interval,
  #           start_date: date,
  #           publication: @vice
  #         )
  #         author.horoscope_count += 1
  #         author.save
  #         handle_keywords(h)
  #       end
  #     end
  #   end
  # end
