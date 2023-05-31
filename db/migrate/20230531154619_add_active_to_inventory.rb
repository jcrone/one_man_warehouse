class AddActiveToInventory < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :active, :string
  end
end
