class CreateOrderTexts < ActiveRecord::Migration[7.0]
  def change
    create_table :order_texts do |t|
      t.string :order_ref, index: true

      t.timestamps
    end
  end
end
