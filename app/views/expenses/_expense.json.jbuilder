json.extract! expense, :id, :amount, :description, :employee_id, :expense_type, :created_at, :updated_at
json.url expense_url(expense, format: :json)
