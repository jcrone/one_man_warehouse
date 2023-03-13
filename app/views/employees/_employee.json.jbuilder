json.extract! employee, :id, :name, :hourly_rate, :email, :created_at, :updated_at
json.url employee_url(employee, format: :json)
