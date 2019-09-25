class MakeZodiacEnum < ActiveRecord::Migration[5.2]
  def change
    change_table :zodiac_signs do |t|
      t.remove :name
      t.integer :name
    end
  end
end
