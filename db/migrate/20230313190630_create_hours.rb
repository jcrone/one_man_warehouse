class CreateHours < ActiveRecord::Migration[7.0]
  def change
    create_table :hours do |t|
      t.belongs_to :employee, null: false, foreign_key: true
      t.decimal :hours
      t.date :start_date
      t.date :end_date
      t.date :pay_date
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
