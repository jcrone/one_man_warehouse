class AddSentToInventory < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :sent, :boolean
  end
end
