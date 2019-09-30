class ElleScraper < Scraper

  def scrape(path)
    puts path
    @sign = find_sign(path)
    type = /(daily|weekly|monthly)/.match(path)&.to_s&.capitalize
    @interval = interval(type)
    @url = @publication.url + path
    doc = open_doc(@url)
    @author = find_author(doc)
    @content = doc.search('.body-text').text.gsub(@advertising_regex, '')
    @date = Time.parse(doc.at(".content-info-date").text)
    build_horoscope
  end

  def find_author(doc)
    raw_author = doc.search(".byline-name").text
    handle_author(raw_author)
  end

  def find_sign(path)
    z = @downcase_z_regex.match(path)&.to_s&.capitalize
    z.nil? ? return : ZodiacSign.find_by(name: z)
  end
end
