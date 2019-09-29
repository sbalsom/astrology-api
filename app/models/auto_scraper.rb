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
      hash = scraper.hzip(text)
      hash.each do |sign, content|
        zodiac = ZodiacSign.find_by(name: sign)
        Horoscope.build_horoscope(content, zodiac, author, 7, date, @autostraddle, link)
      end
    end
  end


  def hzip(node)
    text = node.children.to_enum.map { |x| x.text.strip.gsub(@@advertising_regex, '') }
    # t = text.children.map { |x| x.text.strip.gsub(@@advertising_regex, '') }
    t = text.reject { |x| x == "" }
    t = t.join('~*~')
    signs = t.scan(/~\*~\w{3,20}~\*~/)
    horoscopes = t.split(/~\*~\w{3,20}~\*~/).pop(12)
    h = horoscopes.map {|x| x.gsub(/~\*~/, '')}
    signs = signs.map {|s| s.gsub(/~\*~/, '')}
    binding.pry
    Hash[signs.zip(h)]
  end
end
