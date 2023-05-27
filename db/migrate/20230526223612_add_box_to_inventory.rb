class AddBoxToInventory < ActiveRecord::Migration[7.0]
  def change
    add_reference :inventories, :box, foreign_key: true
  end
end
