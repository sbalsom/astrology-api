class AutoScraper < Scraper

  def scrape(links)
    links.each do |link|
      puts link
      file = open(link)
      doc = Nokogiri::HTML(file)
      text = doc.search('.entry-content')
      # author not working ?
      raw_author = doc.at("a[rel='author']").text
      author = handle_author(raw_author)
      date = Time.parse(doc.at('time').text)
      # this part will be refactored into own class ?
      hash = scraper.auto_zip(text)
      hash.each do |sign, content|
        zodiac = ZodiacSign.find_by(name: sign)
        Horoscope.build_horoscope(content, zodiac, author, 7, date, @autostraddle, link)
      end
    end
  end
end
