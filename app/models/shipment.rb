class Shipment < ApplicationRecord

    has_many_attached :files

    enum :status, { pending: 0, shipped: 1, delivered: 2, issues: 3, delivered_issues: 4}


end
