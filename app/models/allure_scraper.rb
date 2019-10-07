class AllureScraper < Scraper

  def start
    allure_links = compile_links
    allure_links.each do |link|
    doc = open_doc(link)
    scrape(doc, link)
    rescue OpenURI::HTTPError => e
      next if e.message == '404 Not Found'
    end
  end

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
    @author = handle_author(raw_author)
    @content = find_content(doc)
    @sign = find_sign(link)
    @date = find_date(link)
    @url = link
    @interval = 30
    build_horoscope
    @author.handle_socials(doc, ".byline__name-link", @publication, '.social-links a')
    @author.save
  end

  def find_content(doc)
    lede = doc.search('.content-header__dek').text
    body_paragraphs = doc.search('.article__body p')
    body_paragraphs.shift
    body_paragraphs.pop
    b = body_paragraphs.text.gsub(@advertising_regex, '')
    "#{lede} #{b}"
  end

  def find_sign(link)
    raw_sign = link.scan(@downcase_z_regex)
    r = raw_sign[0].capitalize
    ZodiacSign.find_by(name: r)
  end

  def find_date(link)
    months = Date::MONTHNAMES.slice(1, 12).map { |x| x.downcase }
    month = link.scan(Regexp.union(months))
    year = link.scan(/\d{4}/)
    DateTime.parse("1 #{month} #{year}")
  end

end
