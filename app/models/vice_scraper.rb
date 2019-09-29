class ViceScraper < Scraper

  def scrape(links)
    links.each do |link|
      @url = link
      doc = open_doc(link)
      @author = find_author(doc)
      binding.pry
      #not yet saved to db, waiting for the rest
      content = find_content(doc)
      type = determine_type(doc)
      @date = find_date(doc, type)
      @interval = interval(type)
      case @interval
      when @interval < 30
        author.handle_socials(doc, ".contributor__link", @publication, ".contributor__profile__bio a")
        @author.save
        horoscope_hash = hzip(content)
        handle_multiple(horoscope_hash)
      when @interval == 30
        author.handle_socials(doc, ".contributor__link", @publication, ".contributor__profile__bio a")
        @author.save
        @sign = find_sign_from_title(doc)
        @content = content.text.strip.sub(@@advertising_regex, '')
        build_horoscope
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
    raw_content = doc.search('.article__body')
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
    sign = title.scan(@@zodiac_regex)
    ZodiacSign.find_by(name: sign)
  end

  def hzip(content)
    stopwords_regex = /\+(Aries(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Taurus(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Gemini(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Cancer(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Leo(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Virgo(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Libra(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Scorpio(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Sagittarius(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Capricorn(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Aquarius(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?|Pisces(\s\(\w+\s\d{2}\s-\s\w+\s\d{2}\)?)?)\+/
    headers = content.search('h2')
    paragraphs = content.search('p')
    array = paragraphs.to_enum.map {|child| child.text.strip.gsub(@@advertising_regex, "")}
    a = array.reject { |el| el.length < 42 }
    a = a.pop(12)
    h = headers.map { |header| header.text[@@zodiac_regex] }
    h = h.compact
    binding.pry
    Hash[h.zip(a)]
  end
end




  # def set_values(title, raw_author, raw_content, date_published, interval, type, link)
  #    unless /Daily|Weekly/.match(type).nil?
  #       author = handle_author(raw_author)
  #       # type == "Daily" ? date = date_published + 1.days : date = date_published
  #       horoscope_hash = hzip(raw_content)
  #       horoscope_hash.each do |sign, content|
  #         zodiac = ZodiacSign.find_by(name: sign)
  #         build_horoscope(content, zodiac, author, interval, date, @publication, link)
  #       end
  #     end
  #     #  monthlies are handled separately bc they are separate articles
  #     if type == "Monthly"
  #       author = handle_author(raw_author)
  #       sign = title.scan(@@zodiac_regex)
  #       zodiac = ZodiacSign.find_by(name: sign)
  #       content = raw_content.text.strip.sub(@@advertising_regex, '')
  #       build_horoscope(content, zodiac, author, 30, date_published, @publication, link)
  #     end
  #     #  only do this if author is new and variable exists (is a horoscope author)

  # end

