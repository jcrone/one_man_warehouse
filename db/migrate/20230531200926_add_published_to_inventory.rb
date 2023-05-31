class AddPublishedToInventory < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :published, :string
    add_column :inventories, :unpublished_reason, :string
  end
end
