require 'nokogiri'
require 'open-uri'
require 'pry-byebug'

class Horoscope < ApplicationRecord
  belongs_to :publication
  belongs_to :author
  belongs_to :zodiac_sign

  def self.fetch_horoscopes
    # should I create the vice instance in the seed file ? right now it is there
    @vice = Publication.where(name: "Vice").first
    vice_links = compile_links
    vice_links.each do |link|
      html_file = open("https://www.vice.com" + link).read
      html_doc = Nokogiri::HTML(html_file)
      a = html_doc.at("meta[property='article:author']").attributes['content'].value
      z = html_doc.at("meta[name='news_keywords']").attributes['content'].value
      author = handle_author(a)
      zodiac_sign = handle_zodiac(z)
      # need to get sun sign from scrape
      # need to get date
      #  need to get time range
      content = html_doc.search('.article__body').text.strip
      Horoscope.create(
        author: author,
        zodiac_sign: zodiac_sign,
        content: content,
        publication: @vice
      )
    end
    Horoscope.all
    # t.bigint "publication_id"
    # t.bigint "author_id"
    # t.text "content"
    # t.interval "time_range"
    # t.date "start_date"
    # t.bigint "zodiac_sign_id"
    # article_file = open("https://www.vice.com#{}")
  end

  private

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

  def self.handle_zodiac(z)
    @zodiac = ZodiacSign.all
    sign = ZodiacSign.first
    words = z.split(',')
    words.each do |word|
      @zodiac.each do |zodiac|
        if zodiac.name == word
          sign = zodiac
        end
      end
    end
    sign
  end

  def self.compile_links
    vice_links = []
    base_url = 'https://www.vice.com/en_us/topic/horoscopes?page='
    # for i in 1..190 do
    i = 0
    while i <= 2 do
      html_file = open(base_url + i.to_s).read
      html_doc = Nokogiri::HTML(html_file)
      html_doc.search('a.grid__wrapper__card').each do |element|
        a = element.attribute('href').value
        vice_links << a
      end
    puts i
    i += 1
    end
    # perform some rejection on the array of links to get rid of non-horoscope links
    # articles, or do this before in the first scrape (i.e. if title matches on of the patterns then scrape)
    vice_links
  end
end
#     a = element.search('.grid__wraper__card__text__contributor')
    #     if Author.where(full_name: a.text.strip).empty?
    #       puts "creating author #{a.text.strip}"
    #       @author = Author.create(full_name: a.text.strip)
    #     else
    #       puts "referencing author #{a.text.strip}"
    #       @author = Author.where(full_name: a.text.strip)
    #     end
    #     element.search('.grid__wrapper__card__text__title') do |title|
    #       if !title.text.strip.match('Daily Horoscopes: \w+ \d{1,2}, \d{4}').nil?
    #         Horoscope.create(
    #           author: @author,
                #publication: @vice
    #         )
    #       else
    #         puts "not a match"
    #       end
    #     end
    #   end

 # let the scraping begin ! titles , time intervals, taglines, and author names all saved as publication: "Vice"
    # 190 pages total going back to 2015
    # horoscope titles usually standardized to Daily Horoscopes or Weekly Horoscopes or Monthly Horoscopes, or has sign name and month name (2015)
    # in a second scrape, gather horoscopes from every page. but how to do this ? it would need to
    # iterate over horoscope articles and follow each horoscope link
    # (maybe with interpolated url)
    #
    # in another scrape, gather horoscopes from another website
    # save all scrapes into horoscopes model
 #   if title ~= /Daily Horoscopes: \w+ \d{1,2}, \d{4}/
        #    # a pattern that would match to one of the title variants

        #

        #   elsif title ~= /Weekly Horoscope: \w+ \d{1,2} - \d{1,2}/

        #     element.search('.grid__wraper__card__text__contributor').each do |author|
        #       if Author.where(full_name: author.text.strip).empty?
        #         puts "weekly"
        #         Author.create(full_name: author.text.strip)
        #       end
        #     end
        #   elsif title ~= /\w+, \w+ \d{4}/ or title ~= /Your Monthly Horoscope: \w+ \d{4}/

        #     element.search('.grid__wraper__card__text__contributor').each do |author|
        #       if Author.where(full_name: author.text.strip).empty?
        #         puts "monthly"
        #         Author.create(full_name: author.text.strip)
        #       end
        #     end
        #   end
        # end
