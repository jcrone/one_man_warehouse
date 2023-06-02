class AddAmzToInventory < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :amz_qty, :integer
  end
end
