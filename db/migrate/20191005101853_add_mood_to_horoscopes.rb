class AddMoodToHoroscopes < ActiveRecord::Migration[5.2]
  def change
    add_column :horoscopes, :mood, :string
  end
end
