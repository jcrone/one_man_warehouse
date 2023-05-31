class CreateSyncs < ActiveRecord::Migration[7.0]
  def change
    create_table :syncs do |t|
      t.integer :status, default: 0
      t.string :marketplace

      t.timestamps
    end
  end
end
