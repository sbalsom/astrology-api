# require 'pry-byebug'
class ViceScraper < Scraper

  def start(upper_limit)
    main_path = '/en_us/topic/horoscopes?page='
    url = @publication.url + main_path
    links = []
    i = 1
    #  check before final push to make sure all 190 pages are working
    while i <= upper_limit
      puts "compiling"
      links += compile_links(url, 'a.topics-card__heading-link', i)
      i += 1
    end
    scrape(links)
  end

  def scrape(links)
    links.each do |link|
      @url = link
      doc = open_doc(link)
      @author = find_author(doc, ".contributor__link")
      raw_content = doc.search('.article__body')
      type = determine_type(doc)
      @date = find_date(doc, type)
      @interval = interval(type)
      build_by_type(@interval, raw_content, doc)
    end
  end

  def find_date(doc, type)
    date_published = Time.parse(doc.at("meta[name='datePublished']").attributes['content'].value)
    type == "Daily" ? date = date_published + 1.days : date = date_published
    date
  end

  def build_by_type(interval, raw_content, doc)
    case interval
    when 1..7
      @author.handle_socials(doc, ".contributor__link", @publication, ".contributor__profile__bio a")
      @author.save
      horoscope_hash = hzip(raw_content)
      handle_multiples(horoscope_hash)
    when 30
      @author.handle_socials(doc, ".contributor__link", @publication, ".contributor__profile__bio a")
      @author.save
      @sign = find_sign_from_title(doc)
      @content = raw_content.text.strip.sub(@advertising_regex, '')
      build_horoscope
    else
      puts "not a horoscope I can handle, sorry !"
    end
  end

  def determine_type(doc)
    title = doc.at("title").text
    range = title.scan(/(Daily|Weekly|^Monthly)/).flatten
    range[0]
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

