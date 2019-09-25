class CreateZodiacSigns < ActiveRecord::Migration[5.2]
  def change
    create_table :zodiac_signs do |t|
      t.string :name
      t.timestamps
    end
  end
end
