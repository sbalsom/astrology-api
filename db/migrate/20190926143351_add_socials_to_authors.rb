class AddSocialsToAuthors < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :socials, :text
  end
end
