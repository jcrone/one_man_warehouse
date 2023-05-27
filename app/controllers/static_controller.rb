class StaticController < ApplicationController
    require 'base64' 
    require 'securerandom'
    layout "welcome", only: [:welcome]
    require 'catalog-items-api-model'
    require 'fulfillment-outbound-api-model'
    before_action :set_sellbrite, only:[:dashboard]
    before_action :amz_api, only:[:dashboard]
    before_action :walmart_token

    def dashboard
        @unpaid = Hour.where(status: Hour.statuses[:unpaid]).or(Hour.where(status: Hour.statuses[:processing]))
        @pagy, @todos =  pagy(Todo.all)
        @shipments = Shipment.where.not(status: Shipment.statuses[:delivered])
    end 

    private


    def set_sellbrite 
        url = URI("https://api.sellbrite.com/v1/orders?page=1&limit=100&sb_status=open&sb_payment_status=all")
       
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        
        request = Net::HTTP::Get.new(url)
        request["accept"] = 'application/json'
        request["authorization"] = Rails.application.credentials.dig(:sellbrite, :basic_code)
        
        response = http.request(request)
        @orders = handle_response(response)                                                 
        puts @orders
    end 

    def search_walmart
      url = URI("https://marketplace.walmartapis.com/v3/items/walmart/search?upc=​911138034047")
     
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/json'
      request["authorization"] = Rails.application.credentials.dig(:sellbrite, :basic_code)
      request[WM_QOS.CORRELATION_ID""]
      response = http.request(request)
      @walmart = handle_response(response)
      puts @walmart
    end 

    def walmart_token
      if cookies[:wm_access_token].nil?
        client_id = Rails.application.credentials.dig(:walmart, :client_id)
        client_secret = Rails.application.credentials.dig(:walmart, :client_secret)
        authorization = "Basic " + Base64.strict_encode64("#{client_id}:#{client_secret}")
        url = URI("https://marketplace.walmartapis.com/v3/token?grant_type=client_credentials")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        p "🔥: "  + client_id + " : " + client_secret + " : "+ authorization
        request = Net::HTTP::Post.new(url)
        request["accept"] = 'application/json'
        request["authorization"] = "Basic " + Base64.strict_encode64("#{client_id}:#{client_secret}")
        request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
        request["WM_SVC.NAME"] = "Walmart Marketplace"
        response = http.request(request)
        @walmart = handle_response(response)
        p "🔥: " + @walmart.to_s
        if !@walmart["access_token"].nil?
          cookies[:wm_access_token] = { value: @walmart["access_token"], expires: 14.minute }
        end
      end
    end 

    def handle_response(response)
        return JSON.parse(response.body) if Net::HTTPSuccess
    
        error_message = "API request failed with code #{response.code}: #{response.message}"
        raise ApiError, error_message
      rescue JSON::ParserError
        raise ApiError, "Unable to parse JSON response"
    end

    def amz_api

      begin
        api = AmzSpApi::FulfillmentOutboundApiModel::FbaOutboundApi.new(AmzSpApi::SpApiClient.new)
        p api.list_all_fulfillment_orders.payload
      rescue AmzSpApi::ApiError => e
        puts "Exception when calling SP-API: #{e}"
      end

        api_instance = AmzSpApi::CatalogItemsApiModel::CatalogApi.new(AmzSpApi::SpApiClient.new)
        marketplace_ids = ['ATVPDKIKX0DER']# Array<String> | A comma-delimited list of Amazon marketplace identifiers for the request.
        opts = { 
          identifiers: ['195365306376'],
          identifiers_type: 'UPC' # String | Type of product identifiers to search the Amazon catalog for. **Note:** Required when `identifiers` are provided.
        }

        begin
          result = api_instance.search_catalog_items(marketplace_ids, opts)
          p result
        rescue AmzSpApi::CatalogItemsApiModel::ApiError => e
          puts "Exception when calling CatalogApi->search_catalog_items: #{e}"
        end
    end 

end