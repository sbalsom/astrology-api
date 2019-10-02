class CreateTeenVogueScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :teen_vogue_scrapers do |t|

      t.timestamps
    end
  end
end
