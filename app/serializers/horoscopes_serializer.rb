class HoroscopesSerializer < ActiveModel::Serializer
  attributes :id, :content, :range_in_days, :author, :start_date, :zodiac_sign, :keywords, :mood, :original_link, :word_count
end


# create_table "horoscopes", force: :cascade do |t|
#     t.bigint "publication_id"
#     t.bigint "author_id"
#     t.text "content"
#     t.date "start_date"
#     t.bigint "zodiac_sign_id"
#     t.datetime "created_at", null: false
#     t.datetime "updated_at", null: false
#     t.integer "range_in_days"
#     t.string "keywords", default: [], array: true
#     t.string "original_link"
#     t.integer "word_count"
#     t.string "mood"
#     t.index ["author_id"], name: "index_horoscopes_on_author_id"
#     t.index ["publication_id"], name: "index_horoscopes_on_publication_id"
#     t.index ["zodiac_sign_id"], name: "index_horoscopes_on_zodiac_sign_id"
#   end
