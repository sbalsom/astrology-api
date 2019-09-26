class AddRangeToHoroscopes < ActiveRecord::Migration[5.2]
  def change
    change_table :horoscopes do |t|
      t.remove :time_range
      t.integer :range_in_days
    end
  end
end
