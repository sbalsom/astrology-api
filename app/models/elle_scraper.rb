class ElleScraper < Scraper

  def start
    paths = [
      "/horoscopes/daily/",
      "/horoscopes/weekly/",
      "/horoscopes/monthly/"
    ]
    selector = '.simple-item-title'
    elle_paths = []
    paths.each do |p|
      url = @elle.url + p
      elle_paths += compile_links(url, selector)
    end
    elle_paths.each do |path|
      scrape(path)
    end
  end

  def scrape(path)
    puts path
    @sign = find_sign(path)
    type = /(daily|weekly|monthly)/.match(path)&.to_s&.capitalize
    @interval = interval(type)
    @url = @publication.url + path
    doc = open_doc(@url)
    @author = find_author(doc, ".byline-name").save
    @content = doc.search('.body-text').text.gsub(@advertising_regex, '')
    @date = Time.parse(doc.at(".content-info-date").text)
    build_horoscope
  end

  def find_sign(path)
    z = @downcase_z_regex.match(path)&.to_s&.capitalize
    z.nil? ? return : ZodiacSign.find_by(name: z)
  end
end
