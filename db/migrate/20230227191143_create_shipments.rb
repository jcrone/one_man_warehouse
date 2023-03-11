class CreateShipments < ActiveRecord::Migration[7.0]
  def change
    create_table :shipments do |t|
      t.string :shipment_number
      t.string :description
      t.string :shipper
      t.string :tracking
      t.integer :status
      t.datetime :delvery_estmate

      t.timestamps
    end
  end
end
