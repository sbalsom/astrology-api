class TeenVogueScraper < Scraper

  def api_scrape(hit)
    @date = Time.parse(hit['_source']['createdAt'])
    @interval = 7
    @author = find_author_in_api(hit)
    @url = @publication.url + hit['_source']['_links']['archive']['href']
    hit['_source']['items'].each do |item|
      @sign = find_sign_in_api(item)
      @content = ActionView::Base
                 .full_sanitizer
                 .sanitize(item['caption'])
                 .gsub(/\w{2,20}\s\d{1,2}–\w{2,20}\s\d{1,2}/, '')
                 .gsub(@advertising_regex, '')
      build_horoscope
    end
  end

  def find_author_in_api(hit)
    begin
      a = hit['_source']['_embedded']['contributorsAuthor'].first
      a.nil? ? raw_author = "Unknown" : raw_author = a['fields']['name']
      author = handle_author(raw_author)
      s = hit['_source']['_embedded']['contributorsAuthor'].first
      s.nil? ? socials = [] : socials = s['fields']['socialMedia']
      author.handle_simple_socials(socials)
      author.save
      author
    rescue
      binding.pry
    end
  end

  def find_sign_in_api(item)
    sign = item['title']
           .capitalize
           .scan(@zodiac_regex)
           .first
    ZodiacSign.find_by(name: sign)
  end

end

# ['hed']
# ['meta']['createdAt']
