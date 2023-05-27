class AddBrandToInventory < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :brand, :string
    add_column :inventories, :photo_link, :string
  end
end
