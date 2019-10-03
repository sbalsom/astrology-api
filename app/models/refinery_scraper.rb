class RefineryScraper < Scraper
  def start
    url = "https://www.refinery29.com/en-gb/horoscopes?&page="
    i = 1
    while i < 13
      @url = url + i.to_s
      compile_links(@url)
    end
  end

  def compile_links(url)
    doc = open_doc(url)
    paths = doc.search('.card a')
               .to_enum
               .map { |x| x['href'] }
    binding.pry
    paths
  end
end
