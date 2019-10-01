class AutoScraper < Scraper

  def scrape(links)
    links.each do |link|
      puts link
      doc = open_doc(link)
      @author = find_author(doc, "a[rel='author']").save
      @interval = 7
      @date = Time.parse(doc.at('time').text)
      text = doc.search('.entry-content')
      handle_multiples(text)
    end
  end

  def hzip(node)
    text = node.children.to_enum.map { |x| x.text.strip.gsub(@advertising_regex, '') }
    t = text.reject { |x| x == "" }
    t = t.join('~*~')
    signs = t.scan(/~\*~\w{3,20}~\*~/)
    horoscopes = t.split(/~\*~\w{3,20}~\*~/).pop(12)
    h = horoscopes.map { |x| x.gsub(/~\*~/, '') }
    signs = signs.map { |s| s.gsub(/~\*~/, '') }
    Hash[signs.zip(h)]
  end

  def handle_multiples(text)
    hash = hzip(text)
    hash.each do |sign, content|
      @url = link
      @content = content
      @sign = ZodiacSign.find_by(name: sign)
      build_horoscope
    end
  end
end
