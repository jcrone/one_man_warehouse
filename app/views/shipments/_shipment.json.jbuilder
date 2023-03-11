json.extract! shipment, :id, :shipment_number, :description, :shipper, :tracking, :status, :delvery_estmate, :created_at, :updated_at
json.url shipment_url(shipment, format: :json)
