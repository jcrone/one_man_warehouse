class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links do |t|
      t.string :name
      t.string :category
      t.string :link

      t.timestamps
    end
  end
end
