class UnserializeHoroscopeKeywords < ActiveRecord::Migration[5.2]
  def change
    remove_column :horoscopes, :keywords
  end
end
