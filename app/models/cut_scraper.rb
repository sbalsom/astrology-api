class CutScraper < Scraper

  def start
    links = []
    selector = '.main-article-content a'
    i = 0
    while i <= 250
      url = "https://www.thecut.com/tags/astrology/?start=#{i}"
      links += compile_links(url, selector)
      i += 50
    end
    links.each do |link|
      scrape(link)
    end
  end

  def scrape(link)
    return unless /(weekly|week)/.match(link)

    puts "did not return"
    @url = "http:" + link
    doc = open_doc(@url)
    @interval = 7
    @author = find_author(doc, '.article-author')
    @author.save
    puts @url
    @date = Time.parse(doc.at('.article-date').text)
    body = doc.search('.article-content')
    horoscope_hash = cut_zip(body)
    handle_multiples(horoscope_hash)
  end

  def cut_zip(body)
    body.search('div').each { |div| div.remove }
    text = prepare_text(body)
    signs = find_signs(text)
    horoscopes = find_horoscopes(text)
    Hash[signs.zip(horoscopes)]
  end

  def prepare_text(body)
    body = body
           .children
           .to_enum
           .map { |node| node.text.strip.gsub(@advertising_regex, '') }
           .reject { |x| x == "" }
           .join("~*~")
    body
  end

  def find_signs(text)
    text = text
           .scan(/~\*~\w{2,20}\sWeekly Horoscope~\*~/)
           .join('')
           .split(/~\*~~\*~/)
           .map { |x| x.gsub(/(~|\*|\sWeekly\sHoroscope)/, '') }
    text
  end

  def find_horoscopes(text)
    text = text
           .split(/~\*~\w{2,20}\sWeekly Horoscope~\*~/)
           .pop(12)
           .map { |x| x.gsub(/(~|\*)/, '') }
    text
  end

end

# signs = text.scan(/~\*~\w{2,20}\sWeekly Horoscope~\*~/).gsub(/\sWeekly\sHoroscope/, '').split(/~\*~~\*~/).map { |x| x.gsub(/(~|\*)/, '') }
