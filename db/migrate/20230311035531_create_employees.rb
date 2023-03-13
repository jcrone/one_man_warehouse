class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.string :name
      t.decimal :hourly_rate, precision: 8, scale: 2
      t.string :email

      t.timestamps
    end
  end
end
