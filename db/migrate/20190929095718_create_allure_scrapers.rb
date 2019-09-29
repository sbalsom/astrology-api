class CreateAllureScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :allure_scrapers do |t|

      t.timestamps
    end
  end
end
