class CreateScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :scrapers do |t|

      t.timestamps
    end
  end
end
