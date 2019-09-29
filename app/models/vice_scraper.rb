class ViceScraper < Scraper

  def scrape(links)
    links.each do |link|
      doc = open_doc(link)
      #  grabs raw elements from the DOM
      raw_author = doc.at(".contributor__link")&.text
      raw_author = "Unknown" if raw_author.nil?
      date_published = Time.parse(doc.at("meta[name='datePublished']").attributes['content'].value)
      raw_content = doc.search('.article__body')
      title = doc.at("title").text
      # checks the title to see which kind of horoscope it is for handling
      range = title.scan(/(Daily|Weekly|^Monthly)/).flatten
      type = range[0]
      interval = interval(type)
      set_values(title, raw_author, raw_content, date_published, interval)
    end
  end

  private

  def set_values(title, raw_author, raw_content, date_published, interval)
     unless /Daily|Weekly/.match(range[0]).nil?
        author = handle_author(raw_author)
        range[0] == "Daily" ? date = date_published + 1.days : date = date_published
        horoscope_hash = horoscope_zip(raw_content)
        horoscope_hash.each do |sign, content|
          zodiac = ZodiacSign.find_by(name: sign)
          build_horoscope(content, zodiac, author, interval, date, @publication, link)
        end
      end
      #  monthlies are handled separately bc they are separate articles
      if range[0] == "Monthly"
        author = handle_author(raw_author)
        sign = title.scan(@@zodiac_regex)
        zodiac = ZodiacSign.find_by(name: sign)
        content = raw_content.text.strip.sub(@@advertising_regex, '')
        build_horoscope(content, zodiac, author, 30, date_published, @publication, link)
      end
      #  only do this if author is new and variable exists (is a horoscope author)
      if author
        author.handle_socials(doc, ".contributor__link", @publication, ".contributor__profile__bio a")
      end
  end
end
