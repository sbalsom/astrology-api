class CreateAutoScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :auto_scrapers do |t|

      t.timestamps
    end
  end
end
