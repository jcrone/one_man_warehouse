class OrderText < ApplicationRecord
    validates :order_ref, uniqueness: true
end
