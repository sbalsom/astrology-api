require 'spec_helper'

if ZodiacSign.all.length != 12
  ZODIAC = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces']
  ZODIAC.each do |zodiac|
    ZodiacSign.create!(name: zodiac)
  end
end

p = Publication.new(name: "My Pub")
scraper = Scraper.new(p)

describe Scraper do
  it "initializes with an instance of publication" do
    pub = scraper.instance_variable_get(:@publication)
    expect(pub).to be_instance_of(Publication)
    expect(pub.name).to eq("My Pub")
  end

  it "contains an array of every sign as an instance variable" do
    zodiac_signs = scraper.instance_variable_get(:@zodiac_signs)
    expect(zodiac_signs).to be_kind_of(Array)
    expect(zodiac_signs.length).to eq(12)
  end

  it "has an instance variable regexp to check for zodiac names" do
    zodiac_regex = scraper.instance_variable_get(:@zodiac_regex)
    expect(zodiac_regex).to be_kind_of(Regexp)
    expect("Taurus Capricorn Sagittarius").to match(zodiac_regex)
  end

  it "has an instance variable regexp to split zipped horoscopes" do
    zodiac_splitter_regex = scraper.instance_variable_get(:@zodiac_splitter_regex)
    expect(zodiac_splitter_regex).to be_kind_of(Regexp)
    expect("~*~Taurus~*~ ~*~Capricorn~*~ ~*~Sagittarius~*~").to match(zodiac_splitter_regex)
  end

  it "has an instance variable regexp to scrub advertising content" do
    advertising_regex = scraper.instance_variable_get(:@advertising_regex)
    expect(advertising_regex).to be_kind_of(Regexp)
    expect("Subscribe").to match(advertising_regex)
    expect("Click here").to match(advertising_regex)
    expect("Download the app").to match(advertising_regex)
  end

  it "analyzes content" do
    content =  "A really bad day is coming"
    mood = scraper.analyze_content(content)
    expect(mood).to be_kind_of(String)
  end

end


# @zodiac_signs = ZodiacSign.all.map { |sign| sign.name }
#     @zodiac_regex = Regexp.union(@zodiac_signs)
#     @zodiac_splitter_signs = ZodiacSign.all.map { |sign| sign.name + "~*~" }
#     @zodiac_splitter_regex = Regexp.union(@zodiac_splitter_signs)
#     @downcase_zodiac = ZodiacSign.all.map { |sign| sign.name.downcase }
#     @downcase_z_regex = Regexp.union(@downcase_zodiac)
#     @advertising_regex
