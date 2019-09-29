class CreateElleScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :elle_scrapers do |t|

      t.timestamps
    end
  end
end
