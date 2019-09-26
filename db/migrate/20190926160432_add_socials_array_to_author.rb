class AddSocialsArrayToAuthor < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :socials, :string, array: true, default: []
  end
end
