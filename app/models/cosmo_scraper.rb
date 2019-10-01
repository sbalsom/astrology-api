class CosmoScraper < Scraper

  def scrape(path)
    puts path
    @url = @publication.url + path
    doc = open_doc(@url)
    @author = find_author(doc, '.byline-name')
    @date = Time.parse(doc.at('.content-info-date').text)
    if @date < Time.now - 5.years
      puts "its too old"
    else
      handle_by_type(path, doc)
    end
  end

  def handle_by_type(path, doc)
    if (match_data = %r{/(?<sign>\w+)-monthly}.match(path))
      @interval = 30
      @author.save
      handle_monthly(match_data, doc)
    elsif %r{/monthly-horoscope-\w+/}.match(path)
      puts "its trash. go see: #{@url}"
    elsif %r{sex-love}.match(path)
        socialize(@author, doc)
        @interval = 7
        body = doc.search('.article-body-content p')
        handle_sex_love(body)
    elsif %r{weekly-horoscope-\w{3,20}-\d{1,2}-\d{4}}.match(path)
        socialize(@author, doc)
        @interval = 7
        body = doc.search('.article-body-content')
        body.search('div').each { |div| div.remove }
        handle_weeklies(body)
    end
  end

  def handle_monthly(match_data, doc)
    @content = doc.search('.body-text')&.text&.strip&.sub(@advertising_regex, '')
    sign = match_data[:sign].capitalize
    @sign = ZodiacSign.find_by(name: sign)
    build_horoscope
  end

  def handle_weeklies(body)
    horoscope_hash = cosmo_zip(body)
    handle_multiples(horoscope_hash)
  end

  def handle_sex_love(body)
    horoscope_hash = hzip(body)
    handle_multiples(horoscope_hash)
  end

  def cosmo_zip(body)
    t = body&.text&.strip&.gsub(/(\s{2}|\n)/, '')&.split("~*~")&.pop(24)
    horoscopes = t.values_at(* t.each_index.select { |i| i.odd? })
    headers = t.values_at(* t.each_index.select { |i| i.even? })
    h = headers.map(&:capitalize)
    Hash[h.zip(horoscopes)]
  end

  def hzip(body)
    text = body.to_enum.map { |x| x.text.strip.gsub(@advertising_regex, '') }
    t = text.reject { |x| x == "" }
    t = t.join('~*~')
    signs = t.scan(@zodiac_splitter_regex)
    horoscopes = t.split(@zodiac_splitter_regex).pop(12)
    h = horoscopes.map { |x| x.gsub(/~\*~/, '') }
    signs = signs.map { |s| s.gsub(/~\*~/, '') }
    Hash[signs.zip(h)]
  end

  def socialize(author, doc)
    if author.full_name == "Jake Register"
      author.handle_simple_socials(["@jakesastrology", "https://twitter.com/jakesastrology"])
    elsif author.full_name == "Colin Bedell"
      author.handle_simple_socials(["https://www.instagram.com/queercosmos/"])
    else
      # author.handle_socials(doc, '.byline-name', @publication, '.author-header-shares a')
    end
    author.save
  end

end
