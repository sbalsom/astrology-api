class CreateViceScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :vice_scrapers do |t|

      t.timestamps
    end
  end
end
