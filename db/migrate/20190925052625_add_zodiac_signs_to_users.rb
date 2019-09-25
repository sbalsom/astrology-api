class AddZodiacSignsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
    t.references :sun_sign
    t.references :moon_sign
    t.references :rising_sign
    end
  end
end
