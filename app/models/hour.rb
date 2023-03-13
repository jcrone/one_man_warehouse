class Hour < ApplicationRecord
  belongs_to :employee
  enum :status, { unpaid: 0, processing: 1, paid: 2}
end
