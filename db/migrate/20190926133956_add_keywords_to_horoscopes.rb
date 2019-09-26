class AddKeywordsToHoroscopes < ActiveRecord::Migration[5.2]
  def change
    add_column :horoscopes, :keywords, :text
  end
end
