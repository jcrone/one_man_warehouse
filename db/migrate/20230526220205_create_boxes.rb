class CreateBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :boxes do |t|
      t.string :number
      t.belongs_to :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
