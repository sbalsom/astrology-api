class CosmoScraper < Scraper

  def scrape(path)
    url = @cosmo.url + path
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    raw_author = html_doc.at('.byline-name').text.strip
    date = Time.parse(html_doc.at('.content-info-date').text)
    if date < Time.now - 5.years
      puts "too old"
    end

    if a = /\/(?<sign>\w+)-monthly/.match(path)
      author = handle_author(raw_author)
      sign = a[:sign].capitalize
      zodiac = ZodiacSign.find_by(name: sign)
      content = html_doc.search('.body-text')&.text&.strip
      build_horoscope(content, zodiac, author, 30, date, @cosmo, url)
    elsif /\/monthly-horoscope-\w+\//.match(path)
      puts "its trash"
    elsif /sex-love/.match(path)
      puts "its a sex love weekly"
    else
      author = handle_author(raw_author)
      puts "it's a horoscope easily divided !"
      body = html_doc.search('.article-body-content')
      body.search("div").each do |div|
        div.remove
      end
      t = body&.text&.strip&.gsub(/(\s{2}|\n)/, '')&.split("~*~").pop(24)
      horoscopes = t.values_at(* t.each_index.select {|i| i.odd?})
      headers = t.values_at(* t.each_index.select {|i| i.even?})
      h = headers.map(&:capitalize)
      hash = Hash[h.zip(horoscopes)]
      hash.each do |sign, content|
        zodiac = ZodiacSign.find_by(name: sign)
        build_horoscope(content, zodiac, author, 7, date, @cosmo, url)
      end
    end
  end
end
