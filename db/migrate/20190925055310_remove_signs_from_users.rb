class RemoveSignsFromUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.remove :sun_sign_id, :moon_sign_id, :rising_sign_id
    end
  end
end
