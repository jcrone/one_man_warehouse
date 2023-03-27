class CreateExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :expenses do |t|
      t.decimal :amount
      t.text :description
      t.belongs_to :employee, null: false, foreign_key: true
      t.string :expense_type, default: 'expense'
      t.string :status, default: 'unpaid'

      t.timestamps
    end
  end
end
