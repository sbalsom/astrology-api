require 'nokogiri'
require 'open-uri'
require 'pry-byebug'

class Horoscope < ApplicationRecord
  belongs_to :publication
  belongs_to :author
  belongs_to :zodiac_sign

  def self.fetch_vice_horoscopes
    # should I create the vice instance in the seed file ? right now it is there
    @vice = Publication.where(name: "Vice").first
    vice_links = compile_links
    vice_links.each do |link|
      html_file = open("https://www.vice.com" + link).read
      html_doc = Nokogiri::HTML(html_file)
      a = html_doc.at("meta[property='article:author']").attributes['content'].value
      c = html_doc.search('.article__body').text.strip
      t = html_doc.at("title").text
      d = Time.parse(html_doc.at("meta[name='datePublished']").attributes['content'].value)
      w = t.scan(/(Daily|Weekly|^Monthly)/).flatten
      if w[0] == "Daily"
        handle_dailies(c, a, d)
      elsif w[0] == "Weekly"
        handle_weeklies(c, a, d)
      elsif w[0] == "Monthly"
        zodiac = ZodiacSign.all.map { |sign| sign.name }
        s = t.scan(Regexp.union(zodiac))
        z = ZodiacSign.where(name: s).first
        # the sign equals the sign from the title
        handle_monthlies(c, a, z, d)
      end
    end
    Horoscope.all
  end

  def self.handle_dailies(content, author, date)
    a = handle_author(author)
    c = content
    i = 1
    d = date + 1.days
    create_horoscope(c, i, a, d)
  end

  def self.handle_weeklies(content, author, date)
    a = handle_author(author)
    c = content
    i = 7
    d = date
    create_horoscope(c, i, a, d)
  end

  def self.handle_monthlies(content, author, zodiac, date)
    a = handle_author(author)
    if Horoscope.where(content: content).empty?
      Horoscope.create!(
        content: content,
        author: a,
        zodiac_sign: zodiac,
        publication: @vice,
        range_in_days: 30,
        start_date: date
        )
    end
  end

  def self.handle_author(author)
    if Author.where(full_name: author).empty?
      puts "creating author #{author}"
      author = Author.create(full_name: author)
    else
      puts "referencing author #{author}"
      author = Author.where(full_name: author).first
    end
    author
  end

  def self.create_horoscope(content, interval, author, date)
    stopwords = ZodiacSign.all.map { |sign| sign.name }
    stopwords_regex = /(Aries\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Taurus\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Gemini\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Cancer\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Leo\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Virgo\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Libra\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Scorpio\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Sagittarius\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Capricorn\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Aquarius\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)|Pisces\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\))/
    text = content.split(stopwords_regex).collect(&:strip).reject(&:empty?)
    stopwords.each do |s|
      m = "^#{s}"
      text.each_with_index do |word, index|
        matcher = Regexp.new(m)
        next if word !~ matcher

        zodiac = ZodiacSign.where(name: s).first
        kontent = text[index + 1]
        if Horoscope.where(content: kontent).empty?
          Horoscope.create!(
            zodiac_sign: zodiac,
            content: kontent,
            author: author,
            range_in_days: interval,
            start_date: date,
            publication: @vice
          )
        end
      end
    end
  end

  def self.compile_links
    vice_links = []
    base_url = 'https://www.vice.com/en_us/topic/horoscopes?page='
    # for i in 1..190 do
    i = 1
    while i <= 10 do
      html_file = open(base_url + i.to_s).read
      html_doc = Nokogiri::HTML(html_file)
      html_doc.search('a.grid__wrapper__card').each do |element|
        a = element.attribute('href').value
        vice_links << a
      end
    puts i
    i += 1
    end
    vice_links
  end

  # end of the class
end

# I want to add to my database :

# total horoscopes written by each author
# an api view for authors
# keywords for each horoscope (planets, aspects, etc)
# social media links for authors

# 190 pages total going back to 2015

#Allure horoscopes
