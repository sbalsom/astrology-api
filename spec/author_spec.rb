require 'spec_helper'

describe Author do
  it "initializes with the correct attributes" do
    a = Author.new(full_name: "My Name")
    expect(a).to respond_to(:full_name)
    expect(a).to respond_to(:socials)
    expect(a).to respond_to(:horoscopes)
    expect(a).to respond_to(:publications)
  end

  it "can be filtered by params" do
    authors = Author.filter({ full_name: "na", min_count: 300 })
    authors.each do |author|
      expect(author).to be_instance_of(Author)
      expect(author.full_name).to match(/ra/)
      expect(author.min_count).to be >= 300
    end
  end

  it "can add social media links to instance of Author" do
    a = Author.new(full_name: "My Name")
    a.handle_simple_socials(["www.example.com", "www.test.com"])

    expect(a.socials).to be_kind_of(Array)
    expect(a.socials.first).to be_kind_of(String)
  end
end
