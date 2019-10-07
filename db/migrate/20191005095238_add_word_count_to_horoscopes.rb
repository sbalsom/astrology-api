class AddWordCountToHoroscopes < ActiveRecord::Migration[5.2]
  def change
    add_column :horoscopes, :word_count, :integer
  end
end
