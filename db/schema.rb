# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_25_153546) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.string "full_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "horoscopes", force: :cascade do |t|
    t.bigint "publication_id"
    t.bigint "author_id"
    t.text "content"
    t.interval "time_range"
    t.date "start_date"
    t.bigint "zodiac_sign_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_horoscopes_on_author_id"
    t.index ["publication_id"], name: "index_horoscopes_on_publication_id"
    t.index ["zodiac_sign_id"], name: "index_horoscopes_on_zodiac_sign_id"
  end

  create_table "publications", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_zodiac_signs", force: :cascade do |t|
    t.bigint "zodiac_sign_id"
    t.integer "sign_type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_zodiac_signs_on_user_id"
    t.index ["zodiac_sign_id"], name: "index_user_zodiac_signs_on_zodiac_sign_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "zodiac_signs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  add_foreign_key "horoscopes", "authors"
  add_foreign_key "horoscopes", "publications"
  add_foreign_key "horoscopes", "zodiac_signs"
  add_foreign_key "user_zodiac_signs", "users"
  add_foreign_key "user_zodiac_signs", "zodiac_signs"
end
