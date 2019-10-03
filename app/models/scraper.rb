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
# a better way to do regex without escaping / :  %r{}
#  a way to do multiline regex :
# regexp = %r{
#   start         # some text
#   \s            # white space char
#   (group)       # first group
#   (?:alt1|alt2) # some alternation
#   end
# }x
#  come back to this

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
      @author.horoscope_count += 1
      @author.save
      h.handle_keywords
  end
end

  # def hzip(content)
  #   # i can maybe use this as a global method, lets see
  #   headers = content.search('h2')
  #   paragraphs = content.search('p')
  #   array = paragraphs.to_enum.map {|child| child.text.strip.gsub(@advertising_regex, "")}
  #   a = array.reject { |el| el.length < 42 }
  #   a = a.pop(12)
  #   h = headers.map { |header| header.text[@zodiac_regex] }
  #   h = h.compact
  #   Hash[h.zip(a)]
  # end


end


  # def regex_zip(raw_content)
  #   stopwords_regex = /\+(Aries(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Taurus(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Gemini(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Cancer(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Leo(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Virgo(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Libra(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Scorpio(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Sagittarius(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Capricorn(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Aquarius(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Pisces(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?)\+/
  #   headers = raw_content.search('h2')
  #   paragraphs = raw_content.search('p')
  #   array = paragraphs.to_enum.map {|child| child.text.strip.gsub(@@advertising_regex, "")}
  #   a = array.reject { |el| el.length < 42 }
  #   a = a.pop(12)
  #   h = headers.map { |header| header.text[@@zodiac_regex] }
  #   h = h.compact
  #   binding.pry
  #   Hash[h.zip(a)]
  # end

  # def auto_zip(node)
  #   text = node.children.to_enum.map { |x| x.text.strip.gsub(@@advertising_regex, '') }
  #   # t = text.children.map { |x| x.text.strip.gsub(@@advertising_regex, '') }
  #   t = text.reject { |x| x == "" }
  #   t = t.join('~*~')
  #   signs = t.scan(/~\*~\w{3,20}~\*~/)
  #   horoscopes = t.split(/~\*~\w{3,20}~\*~/).pop(12)
  #   h = horoscopes.map {|x| x.gsub(/~\*~/, '')}
  #   signs = signs.map {|s| s.gsub(/~\*~/, '')}
  #   binding.pry
  #   Hash[signs.zip(h)]
  # end
  # def visit_links(url, selector)
  #   file = open(url).read
  #   doc = Nokogiri::HTML(file)
  #   doc.search(selector)
  # end


    # paths.each do |p|
    #   links << p&.attributes['href']&.value
    # end
    # binding.pry
    # # paths = links.map {|l| l&.attributes&['href']&.value }
    # doc.search(selector).each do |element|
    #   a = element&.attributes['href']&.value
    #   links << a
    # end
    # links
