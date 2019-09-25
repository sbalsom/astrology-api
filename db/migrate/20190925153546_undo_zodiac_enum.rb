class UndoZodiacEnum < ActiveRecord::Migration[5.2]
  def change
    change_table :zodiac_signs do |t|
      t.remove :name
      t.string :name
    end
  end
end
