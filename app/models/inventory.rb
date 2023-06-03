class Inventory < ApplicationRecord
  belongs_to :location
  belongs_to :box


  def self.to_csv(fields = column_names, options={})
    CSV.generate(headers: true) do |csv|
      csv << fields
      all.each do |inventory|
        csv << inventory.attributes.merge(inventory.location.attributes).merge(inventory.box.attributes).values_at(*fields)
      end
    end
  end


end
