class AddQtyToInventory < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :qty, :integer
  end
end
