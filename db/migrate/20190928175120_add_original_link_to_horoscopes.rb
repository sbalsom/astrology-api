class AddOriginalLinkToHoroscopes < ActiveRecord::Migration[5.2]
  def change
    add_column :horoscopes, :original_link, :string
  end
end
