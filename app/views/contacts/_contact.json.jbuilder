json.extract! contact, :id, :first_name, :last_name, :company, :address, :phone, :notes, :email, :created_at, :updated_at
json.url contact_url(contact, format: :json)
