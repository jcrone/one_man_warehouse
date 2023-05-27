class Box < ApplicationRecord
  belongs_to :location
  has_many :inventories
end
