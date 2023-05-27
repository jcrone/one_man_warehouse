class Location < ApplicationRecord
    has_many :boxes, dependent: :destroy
end
