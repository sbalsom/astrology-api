class AllureScraper < Scraper

  def compile_links
    links = []
    year = Time.now.year
    months = Date::MONTHNAMES.slice(1, 12).map { |x| x.downcase }
    zodiac = ZodiacSign.all.map { |s| s.name.downcase }
    months.each do |month|
      zodiac.each do |sign|
        links << "https://www.allure.com/story/#{sign}-horoscope-#{month}-#{year}"
      end
    end
    links
  end

  def scrape(doc, link)
    raw_author = doc.search('.byline__name-link').text
    author = handle_author(raw_author)
    lede = doc.search('.content-header__dek').text
    body_paragraphs = doc.search('.article__body p')
    body_paragraphs.shift
    body_paragraphs.pop
    b = body_paragraphs.text.gsub(@@advertising_regex, '')
    content = "#{lede} #{b}"
    # zodiac_signs = ZodiacSign.all.map { |sign| sign.name.downcase }
    months = Date::MONTHNAMES.slice(1, 12).map { |x| x.downcase }
    raw_sign = link.scan(@@downcase_z_regex)
    r = raw_sign[0].capitalize
    sign = ZodiacSign.find_by(name: r)
    month = link.scan(Regexp.union(months))
    year = link.scan(/\d{4}/)
    date = DateTime.parse("1 #{month} #{year}")
    build_horoscope(content, sign, author, 30, date, @allure, link)
    # handle allure socials
    author.handle_socials(doc, ".byline__name-link", @allure, '.social-links a')
  end

end
