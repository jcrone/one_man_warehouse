class Expense < ApplicationRecord
  belongs_to :employee
  has_many_attached :expense_docs
end
