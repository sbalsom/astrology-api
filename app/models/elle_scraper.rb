class ElleScraper < Scraper

  def scrape(path, zodiac, interval)
    url = @elle.url + path
    file = open(url)
    doc = Nokogiri::HTML(file)
    raw_author = doc.search(".byline-name").text
    author = handle_author(raw_author)
    content = doc.search('.body-text').text
    date = Time.parse(doc.at(".content-info-date").text)
    build_horoscope(content, zodiac, author, interval, date, @elle, url)
  end
end
