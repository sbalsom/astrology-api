class CreateUserZodiacSigns < ActiveRecord::Migration[5.2]
  def change
    create_table :user_zodiac_signs do |t|
      t.references :zodiac_sign, foreign_key: true
      t.integer :sign_type
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
