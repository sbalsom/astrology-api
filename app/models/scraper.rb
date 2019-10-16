require 'nokogiri'
require 'open-uri'

class Scraper < ApplicationRecord

  def initialize(publication)
    @publication = publication
    @zodiac_signs = ZodiacSign.all.map { |sign| sign.name }
    @zodiac_regex = Regexp.union(@zodiac_signs)
    @zodiac_splitter_signs = ZodiacSign.all.map { |sign| sign.name + "~*~" }
    @zodiac_splitter_regex = Regexp.union(@zodiac_splitter_signs)
    @downcase_zodiac = ZodiacSign.all.map { |sign| sign.name.downcase }
    @downcase_z_regex = Regexp.union(@downcase_zodiac)
    @advertising_regex = /(Stick to your course and your goals with a little help from Moon Club\w{15,100}\.|Make sure to ‘Like’ us on Facebook to stay in the know!|Want more Teen Vogue?|Like us on Facebook to stay in the know!|The weekly horoscope for the week of \w{3,30}\s\d{1,2} will be here|Read the weekly horoscope for the week of\s\w{3,20}\s\d{1,2}\shere|\s{2}|\n|^Your Key Dates|See All Signs|Want these horoscopes sent straight to your inbox?|Click here to sign up for the newsletter\.|Download the Astro Guide app by VICE on an iOS device |to read daily horoscopes personalized for your sun, moon, and rising signs| Read your monthly horoscope here\.|What's in the stars for you in \w{4,20}\?|Read more stories about astrology:|These are the signs you're most compatible with romantically:|All times ET\.|All times EST\.|Subscribe|Want to get the hottest sex positions, the wildest confessions, and the steamiest secrets right to your inbox?|Sign up for our sex newsletter ASAP|)/
  end

  def analyze_content(content)
    analyzer = SentimentLib::Analyzer.new
    score = analyzer.analyze(content)
    @mood = verbalize(score)
  end

  def verbalize(score)
    case score
    when -20..-16
      return "Turbulent"
    when -15..-11
      return "Difficult"
    when -10..-6
      return "Trying"
    when -5..-1
      return "Worrisome"
    when 0
      return "Neutral"
    when 1..5
      return "Reassuring"
    when 6..10
      return "Promising"
    when 11..20
      return "Life-affirming"
    else
      return "Off the charts"
    end
  end

  def compile_links(base_url, selector, query = '')
    doc = open_doc(base_url + query.to_s)
    paths = doc.search(selector)
    paths.map { |l| l&.attributes['href']&.value }
  end

  def find_author(doc, selector)
    raw_author = doc.at(selector)&.text&.strip
    raw_author = "Unknown" if raw_author.nil?
    handle_author(raw_author)
  end

  def open_doc(url)
    file = open(url).read
    Nokogiri::HTML(file)
  end

  def handle_author(author)
    if author == "Annabel Get"
      author = "Annabel Gat"
    elsif author == "The AstroTwinsThe AstroTwins"
      author = "Tali and Ophira Edut"
    elsif author == "The AstroTwins"
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

  def handle_multiples(horoscope_hash)
    horoscope_hash.each do |sign, content|
      @content = content
      @sign = ZodiacSign.find_by(name: sign)
      build_horoscope
    end
  end

  def build_horoscope
    analyze_content(@content)
    @content = "#{@content.truncate(100)}... #{@content.split(' ').count} words by #{@author.full_name}. Read the original at #{@url}"
    if Horoscope.where(content: @content).empty?
      h = Horoscope.create(
        zodiac_sign: @sign,
        content: @content,
        author: @author,
        range_in_days: @interval,
        start_date: @date,
        publication: @publication,
        original_link: @url,
        word_count: @content.split(' ').count,
        mood: @mood
      )
      @author.horoscope_count += 1
      @author.save
      h.handle_keywords
    end
  end
end
