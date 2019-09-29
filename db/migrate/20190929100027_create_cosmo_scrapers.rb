class CreateCosmoScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :cosmo_scrapers do |t|

      t.timestamps
    end
  end
end
