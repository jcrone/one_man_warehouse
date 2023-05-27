class OrdersController < ApplicationController
    before_action :search_amazon
    def index

    end 

    private
    # def search_amazon
   
    #       api_instance = AmzSpApi::CatalogItemsApiModel::CatalogApi.new(AmzSpApi::SpApiClient.new)
    #       marketplace_ids = ['ATVPDKIKX0DER']# Array<String> | A comma-delimited list of Amazon marketplace identifiers for the request.
    #       opts = { 
    #         identifiers: ['043475724248'],
    #         identifiers_type: 'UPC', # String | Type of product identifiers to search the Amazon catalog for. **Note:** Required when `identifiers` are provided.
    #         included_data: ['summaries','images', 'identifiers'], 
    #         sellerId: 'A1D0Y0NHVHIBRG'
    #       }

    #       begin
    #         @amazon_search = api_instance.search_catalog_items(marketplace_ids, opts)
    #         p @amazon_search
    #       rescue AmzSpApi::CatalogItemsApiModel::ApiError => e
    #         puts "Exception when calling CatalogApi->search_catalog_items: #{e}"
    #       end
    #       if @amazon_search.number_of_results > 0
    #         @amazon_search_asin = @amazon_search.items.first[:asin]
    #         @amazon_search_photo = @amazon_search.items.first[:images].first[:images][1][:link]
    #         @amazon_search_size  = @amazon_search.items.first[:summaries].first[:size]
    #         @amazon_search_brand  = @amazon_search.items.first[:summaries].first[:brand]
    #         @amazon_search_color  = @amazon_search.items.first[:summaries].first[:color]
    #         @amazon_search_itemName  = @amazon_search.items.first[:summaries].first[:itemName]
    #         @amazon_link = "https://sellercentral.amazon.com/product-search/search?q=#{@upc}"
    #       end 
    #   end 
end 