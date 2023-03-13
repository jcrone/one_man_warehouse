class CreateTodos < ActiveRecord::Migration[7.0]
  def change
    create_table :todos do |t|
      t.string :name
      t.string :description
      t.date :due_date
      t.integer :todo_status

      t.timestamps
    end
  end
end
