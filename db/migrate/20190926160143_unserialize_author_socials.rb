class UnserializeAuthorSocials < ActiveRecord::Migration[5.2]
  def change
    remove_column :authors, :socials
  end
end

