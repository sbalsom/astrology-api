# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
puts "destroying old data"

Horoscope.destroy_all
Publication.destroy_all
Author.destroy_all
ZodiacSign.destroy_all

puts "creating publications"

Publication.create(name: "Vice")
Publication.create(name: "Allure")
Publication.create(name: "Astro.com")

puts "#{Publication.count} publications created"

puts "making the zodiac"
ZODIAC = ['Aries', 'Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces']
ZODIAC.each do |zodiac|
  ZodiacSign.create!(name: zodiac)
end

puts "#{ZodiacSign.count} signs created"
