require 'nokogiri'
require 'open-uri'
# require 'watir'
require 'pry-byebug'
require 'net/http'


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
    matches.each do |match|
      horoscope.keywords << match unless horoscope.keywords.include?(match)
    end
    horoscope.save
  end

  def self.compile_links(base_url, selector, query)
    puts base_url
    puts query
    links = []
    html_file = open(base_url + query.to_s).read
    html_doc = Nokogiri::HTML(html_file)
    html_doc.search(selector).each do |element|
      a = element.attribute('href').value
      links << a
      binding.pry
    end
    puts links
    links
  end

  def self.handle_socials(base_url, path, selector, author)
    html_file = open(base_url + path).read
    html_doc = Nokogiri::HTML(html_file)
    socials = html_doc.search(selector)
    socials.each do |s|
      link = s.attributes['href'].value
      author.socials << link unless author.socials.include?(link)
      author.save
    end
  end

  # vice methods

  def self.fetch_vice_horoscopes
    # should I create the vice instance in the seed file ? right now it is there
    @vice = Publication.find_by(name: "Vice")
    base_url = 'https://www.vice.com'
    main_path = '/en_us/topic/horoscopes?page='
    b = base_url + main_path
    puts b
    vice_links = []
    i = 1
    # while i <= 190 do
    while i <= 3 do
      puts i
      vice_links += compile_links(b, 'a.grid__wrapper__card', i)
      puts vice_links
      i += 1
    end
    puts vice_links
    # this could be factored into its own method for brevity
    vice_links.each do |link|
      puts "in the second loop"
      html_file = open(base_url + link).read
      html_doc = Nokogiri::HTML(html_file)
      raw_author = html_doc.at("meta[property='article:author']").attributes['content'].value
      raw_content = html_doc.search('.article__body').text.strip
      raw_title = html_doc.at("title").text
      raw_date = Time.parse(html_doc.at("meta[name='datePublished']").attributes['content'].value)
      range = raw_title.scan(/(Daily|Weekly|^Monthly)/).flatten
      social_path = html_doc.at(".contributor__link").attributes['href'].value
      social_selector = ".contributor__profile__bio a"
      if range[0] == "Daily"
        puts "daily found"
        author = handle_author(raw_author)
        handle_socials(base_url, social_path, social_selector, author)
        content = raw_content
        interval = 1
        date = raw_date + 1.days
        create_vice_horoscope(content, interval, author, date)
      elsif range[0] == "Weekly"
        puts "weekly found"
        author = handle_author(raw_author)
        handle_socials(base_url, social_path, social_selector, author)
        content = raw_content
        interval = 7
        date = raw_date
        create_vice_horoscope(content, interval, author, date)
      elsif range[0] == "Monthly"
        puts "monthly found"
        zodiac_signs = ZodiacSign.all.map { |sign| sign.name }
        sign = raw_title.scan(Regexp.union(zodiac_signs))
        zodiac = ZodiacSign.find_by(name: sign)
        content = raw_content.sub("Download the Astro Guide app by VICE on an iOS device to read daily horoscopes personalized for your sun, moon, and rising signs, and learn how to apply cosmic events to self care, your friendships, and relationships.", '')
        author = handle_author(raw_author)
        date = raw_date
        handle_socials(base_url, social_path, social_selector, author)
        handle_vice_monthlies(content, author, zodiac, date)
      end
    end
    Horoscope.all
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
    zodiac_signs = ZodiacSign.all.map { |sign| sign.name.downcase }
    months = Date::MONTHNAMES.slice(1, 12).map { |x| x.downcase }
    raw_sign = link.scan(Regexp.union(zodiac_signs))
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
    base_url = 'https://www.allure.com'
    social_path = doc.at(".byline__name-link").attributes['href'].value
    selector = '.social-links a'
    handle_socials(base_url, social_path, selector, author)
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

