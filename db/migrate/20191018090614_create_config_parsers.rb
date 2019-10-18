class CreateConfigParsers < ActiveRecord::Migration[5.2]
  def change
    create_table :config_parsers do |t|

      t.timestamps
    end
  end
end
