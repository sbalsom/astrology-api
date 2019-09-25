class CreatePublications < ActiveRecord::Migration[5.2]
  def change
    create_table :publications do |t|
      t.string :name
      t.timestamps
    end
  end
end
