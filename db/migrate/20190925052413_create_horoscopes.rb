class CreateHoroscopes < ActiveRecord::Migration[5.2]
  def change
    create_table :horoscopes do |t|
      t.references :publication, foreign_key: true
      t.references :author, foreign_key: true
      t.text :content
      t.interval :time_range
      t.date :start_date
      t.references :zodiac_sign, foreign_key: true
      t.timestamps
    end
  end
end
