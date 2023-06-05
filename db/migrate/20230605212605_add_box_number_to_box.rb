class AddBoxNumberToBox < ActiveRecord::Migration[7.0]
  def change
    add_column :boxes, :box_number, :integer
  end
end
