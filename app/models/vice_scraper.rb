# require 'pry-byebug'
class ViceScraper < Scraper

  def scrape(links)
    links.each do |link|
      @url = link
      doc = open_doc(link)
      @author = find_author(doc)
      #not yet saved to db, waiting for the rest
      content = find_content(doc)
      type = determine_type(doc)
      @date = find_date(doc, type)
      @interval = interval(type)
      case @interval
      when 1..7
        @author.handle_socials(doc, ".contributor__link", @publication, ".contributor__profile__bio a")
        @author.save
        horoscope_hash = hzip(content)
        handle_multiple(horoscope_hash)
      when 30
        @author.handle_socials(doc, ".contributor__link", @publication, ".contributor__profile__bio a")
        @author.save
        @sign = find_sign_from_title(doc)
        @content = content.text.strip.sub(@advertising_regex, '')
        build_horoscope
      else
        puts "not a horoscope I can handle, sorry !"
      end
    end
  end

  def find_author(doc)
    raw_author = doc.at(".contributor__link")&.text
    raw_author = "Unknown" if raw_author.nil?
    handle_author(raw_author)
  end

  def find_date(doc, type)
    date_published = Time.parse(doc.at("meta[name='datePublished']").attributes['content'].value)
    type == "Daily" ? date = date_published + 1.days : date = date_published
    date
  end

  def find_content(doc)
    doc.search('.article__body')
  end

  def determine_type(doc)
    title = doc.at("title").text
    range = title.scan(/(Daily|Weekly|^Monthly)/).flatten
    range[0]
  end

  def handle_multiple(horoscope_hash)
    horoscope_hash.each do |sign, content|
      @content = content
      @sign = ZodiacSign.find_by(name: sign)
      build_horoscope
    end
  end

  def find_sign_from_title(doc)
    title = doc.at("title").text
    sign = title.scan(@zodiac_regex)
    ZodiacSign.find_by(name: sign)
  end

  def hzip(content)
    headers = content.search('h2')
    paragraphs = content.search('p')
    array = paragraphs.to_enum.map {|child| child.text.strip.gsub(@advertising_regex, "") }
    a = array.reject { |el| el.length < 42 }
    a = a.pop(12)
    h = headers.map { |header| header.text[@zodiac_regex] }
    h = h.compact
    Hash[h.zip(a)]
  end
end

