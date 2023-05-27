class AddMarketplaceToInventory < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :marketplace, :string
  end
end
