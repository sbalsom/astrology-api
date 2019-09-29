require 'nokogiri'
require 'open-uri'

class Scraper < ApplicationRecord
  def initialize(publication)
    @publication = publication
  end

  @@zodiac_signs = ZodiacSign.all.map { |sign| sign.name }
  @@zodiac_regex = Regexp.union(@@zodiac_signs)
  @@downcase_zodiac = ZodiacSign.all.map { |sign| sign.name.downcase }
  @@downcase_z_regex = Regexp.union(@@downcase_zodiac)
  # ADVERTISING_PHRASES = [
  #   "Download the Astro Guide app by VICE on an iOS device",
  #   "to read daily horoscopes personalized for your sun, moon, and rising signs,",
  #   "and learn how to apply cosmic events to self care, your friendships, and relationships.",
  #   "Read your monthly horoscope here.",
  #   "Want these horoscopes sent straight to your inbox?",
  #   "Click here to sign up for the newsletter.",
  #   "What's in the stars for you in \w{4,20}\?",
  #   "Read more stories about astrology:",
  #   "These are the signs you're most compatible with romantically:",
  #   "All times ET.",
  #   "All times EST."
  # ]
  # @@advertising_regex = Regexp.union(ADVERTISING_PHRASES)

  @@advertising_regex = /(Want these horoscopes sent straight to your inbox?|Click here to sign up for the newsletter.|Download the Astro Guide app by VICE on an iOS device |to read daily horoscopes personalized for your sun, moon, and rising signs| Read your monthly horoscope here.|What's in the stars for you in \w{4,20}\?|Read more stories about astrology:|These are the signs you're most compatible with romantically:|All times ET.|All times EST.)/

  def compile_links(base_url, selector, query = '')
    links = []
    html_file = open(base_url + query.to_s).read
    html_doc = Nokogiri::HTML(html_file)
    html_doc.search(selector).each do |element|
      a = element.attributes['href'].value
      links << a
    end
    links
  end

  def visit_links(url, selector)
    file = open(url).read
    doc = Nokogiri::HTML(file)
    text = doc.search(selector)
    auto_zip(text)
  end

  def open_doc(url)
    file = open(url).read
    Nokogiri::HTML(file)
  end

  def regex_zip(raw_content)
    stopwords_regex = /\+(Aries(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Taurus(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Gemini(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Cancer(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Leo(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Virgo(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Libra(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Scorpio(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Sagittarius(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Capricorn(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Aquarius(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Pisces(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?)\+/
    headers = raw_content.search('h2')
    paragraphs = raw_content.search('p')
    array = paragraphs.to_enum.map {|child| child.text.strip.gsub(@@advertising_regex, "")}
    a = array.reject { |el| el.length < 42 }
    a = a.pop(12)
    h = headers.map { |header| header.text[@@zodiac_regex] }
    h = h.compact
    binding.pry
    Hash[h.zip(a)]
  end

  def auto_zip(node)
    text = node.children.to_enum.map { |x| x.text.strip.gsub(@@advertising_regex, '') }
    # t = text.children.map { |x| x.text.strip.gsub(@@advertising_regex, '') }
    t = text.reject { |x| x == "" }
    t = t.join('~*~')
    signs = t.scan(/~\*~\w{3,20}~\*~/)
    horoscopes = t.split(/~\*~\w{3,20}~\*~/).pop(12)
    h = horoscopes.map {|x| x.gsub(/~\*~/, '')}
    signs = signs.map {|s| s.gsub(/~\*~/, '')}
    binding.pry
    Hash[signs.zip(h)]
  end

  def handle_author(author)
    if author == "Annabel Get"
      author = "Annabel Gat"
    elsif author == "The AstroTwinsThe AstroTwins"
      author = "Tali and Ophira Edut"
    elsif author == "Aliza Kelly Faragher"
      author = "Aliza Kelly"
    elsif author == "Corina"
      author = "Corina Dross"
    end
    if Author.where(full_name: author).empty?
      puts "creating author #{author}"
      author = Author.new(full_name: author)
    else
      puts "referencing author #{author}"
      author = Author.find_by(full_name: author)
    end
    author
  end

   def interval(string)
    return 1 if string == "Daily"
    return 7 if string == "Weekly"
    return 30 if string == "Monthly"
    return 99 if string.nil?
  end

  def self.build_horoscope
  if Horoscope.where(content: @content).empty?
      h = Horoscope.create(
        zodiac_sign: @sign,
        content: @content,
        author: @author,
        range_in_days: @interval,
        start_date: @date,
        publication: @publication,
        original_link: @url
      )
      author.horoscope_count += 1
      author.save
      h.handle_keywords
  end
end


end
