class Scraper < ApplicationRecord
  def initialize(publication)
    @publication = publication
  end

  def compile_links(base_url, selector, query = '')
    links = []
    html_file = open(base_url + query.to_s).read
    html_doc = Nokogiri::HTML(html_file)
    html_doc.search(selector).each do |element|
      a = element.attributes['href'].value
      links << a
    end
    links
  end

  def visit_links(url, selector)
    file = open(url).read
    doc = Nokogiri::HTML(file)
    text = doc.search(selector)
    auto_zip(text)
  end

  def auto_zip(text)
    text.to_enum.map(&:text)
    t = text.children.map { |x| x.text.strip }
    t = t.reject { |x| x == "" }
    t = t.join('~*~')
    signs = t.scan(/~\*~\w{3,20}~\*~/)
    horoscopes = t.split(/~\*~\w{3,20}~\*~/).pop(12)
    h = horoscopes.map {|x| x.gsub(/~\*~/, '')}
    signs = signs.map {|s| s.gsub(/~\*~/, '')}
    Hash[signs.zip(h)]
  end

  def handle_author(author)
    if author == "Annabel Get"
      author = "Annabel Gat"
    elsif author == "The AstroTwinsThe AstroTwins"
      author = "Tali and Ophira Edut"
    elsif author == "Aliza Kelly Faragher"
      author = "Aliza Kelly"
    elsif author == "Corina"
      author = "Corina Dross"
    end
    if Author.where(full_name: author).empty?
      puts "creating author #{author}"
      author = Author.create(full_name: author)
    else
      puts "referencing author #{author}"
      author = Author.find_by(full_name: author)
    end
    author
  end

   def interval(string)
    return 1 if string == "Daily"
    return 7 if string == "Weekly"
    return 30 if string == "Monthly"
  end
end
