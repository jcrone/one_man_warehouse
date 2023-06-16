class WalmartInventoryJob < ApplicationJob
    require './app/services/walmart_inventory'
    queue_as :default
  
    def perform(authorization)
        @authorization = authorization
        WalmartInventory.new.add_walmart_skus(@authorization)
    end 

    
  end