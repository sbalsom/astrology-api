class CreateCutScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :cut_scrapers do |t|

      t.timestamps
    end
  end
end
