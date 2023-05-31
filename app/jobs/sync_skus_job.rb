class SyncSkusJob < ApplicationJob
    require './app/services/amazon_client'
    require './app/services/walmart_client'
    queue_as :default
  
    def perform(authorization)
        @inventory_amazon = Inventory.where(marketplace: "amazon").where(sku: nil)
        @authorization = authorization
        AmazonClient.new.add_skus(@inventory_amazon)
        WalmartClient.new.add_walmart_skus(@authorization)
    end 

  end