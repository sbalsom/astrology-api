class CreateRefineryScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :refinery_scrapers do |t|

      t.timestamps
    end
  end
end
