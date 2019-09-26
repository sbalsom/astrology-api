class AddKeywordsArrayToHoroscopes < ActiveRecord::Migration[5.2]
  def change
    add_column :horoscopes, :keywords, :string, array: true, default: []
  end
end
