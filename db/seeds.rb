
# Horoscope.destroy_all
# Publication.destroy_all
# Author.destroy_all
# # ZodiacSign.destroy_all

puts "creating publications"

# ONLY ONCE

Publication.create(name: "Vice", url: "https://www.vice.com")
Publication.create(name: "Allure", url: "https://www.allure.com/")
Publication.create(name: "Elle", url: "https://www.elle.com")
Publication.create(name: "Cosmopolitan", url: "https://www.cosmopolitan.com")
Publication.create(name: "Mask Magazine", url: "http://www.maskmagazine.com")
Publication.create(name: "The Cut", url: "https://www.thecut.com")
Publication.create(name: "Teen Vogue", url: "https://www.teenvogue.com")
Publication.create(name: "Autostraddle", url: "https://www.autostraddle.com")
# Publication.create(name: "Refinery 29", url: "https://www.refinery29.com/")

puts "#{Publication.count} publications created"


puts "making the zodiac"

ZODIAC = ['Aries', 'Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces']
ZODIAC.each do |zodiac|
   ZodiacSign.create!(name: zodiac)
end

puts "#{ZodiacSign.count} signs created"

Horoscope.fetch_vice_horoscopes(190)
Horoscope.fetch_allure_horoscopes
Horoscope.fetch_autostraddle_horoscopes
Horoscope.fetch_elle_horoscopes
Horoscope.fetch_cosmo_horoscopes(70)
Horoscope.fetch_mask_horoscopes
Horoscope.fetch_cut_horoscopes(250)
Horoscope.fetch_teen_vogue_horoscopes(10)
# Horoscope.fetch_refinery_horoscopes

