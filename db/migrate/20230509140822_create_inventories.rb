class CreateInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories do |t|
      t.string :upc
      t.string :sku
      t.string :asin
      t.string :description
      t.belongs_to :location, optional: true , foreign_key: true

      t.timestamps
    end
  end
end
