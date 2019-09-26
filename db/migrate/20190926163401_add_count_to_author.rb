class AddCountToAuthor < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :horoscope_count, :integer
  end
end
