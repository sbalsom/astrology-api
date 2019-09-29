class CreateMaskScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :mask_scrapers do |t|

      t.timestamps
    end
  end
end
