class MaskScraper < Scraper

  def scrape(path)
    raw_author = "Corina Dross"
    @author = handle_author(raw_author)
    @url = @publication.url + path
    @interval = 30
    if /aril-2018/.match(path)
      @date = Time.parse("April 1 2018")
    else
      @date = Time.parse(path)
    end
    doc = open_doc(@url)
    body = doc.search('.body')
    hash = mask_zip(body)
    handle_multiples(hash)
    @author.handle_one_step_socials(doc, '.author-summary a')
  end

  def mask_zip(body)
    text = body.children.to_enum.map { |x| x.text.strip.gsub(@advertising_regex, '') }
    t = text.reject { |x| x == "" }
    t = t.join('~*~')
    signs = t.scan(@zodiac_splitter_regex)
    horoscopes = t.split(@zodiac_splitter_regex).pop(12)
    h = horoscopes.map { |x| x.gsub(/~\*~/, '') }
    signs = signs.map { |s| s.gsub(/~\*~/, '') }
    Hash[signs.zip(h)]
  end
end
