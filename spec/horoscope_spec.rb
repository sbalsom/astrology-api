require 'spec_helper'

a = Author.new(full_name: "My Name")
  p = Publication.new(name: "My Publication", url: "www.example.com")
  z = ZodiacSign.new(name: "Thirteenth Sign")
  h = Horoscope.new(
    publication: p,
    author: a,
    range_in_days: 7,
    zodiac_sign: z,
    keywords: ["moon"],
    original_link: "www.example.com",
    word_count: 300,
    mood: "Trying",
    start_date: Time.now,
    content: "dummy content dummy content dummy content dummy content dummy content dummy content"
  )

describe Horoscope do
  it "initializes with the correct attributes" do
    expect(h).to respond_to(:zodiac_sign)
    expect(h).to respond_to(:content)
    expect(h).to respond_to(:author)
    expect(h).to respond_to(:start_date)
    expect(h).to respond_to(:range_in_days)
    expect(h).to respond_to(:keywords)
  end

  it "attributes save the correct kind of data" do
    expect(h.keywords).to be_kind_of(Array)
    expect(h.author).to be_instance_of(Author)
    expect(h.publication).to be_instance_of(Publication)
    expect(h.zodiac_sign).to be_instance_of(ZodiacSign)
    expect(h.range_in_days).to be_kind_of(Integer).and be <= 30
    expect(h.content).to be_kind_of(String)
    expect(h.start_date).to be_kind_of(Date)
    expect(h.mood).to be_kind_of(String)
    expect(h.original_link).to match(/\w+\.\w+\.\w{2,3}/)
  end

end
