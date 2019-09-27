class UndoLastMigration < ActiveRecord::Migration[5.2]
  def change
    remove_column :authors, :horoscope_count
  end
end
