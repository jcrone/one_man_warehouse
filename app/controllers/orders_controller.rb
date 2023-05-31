class OrdersController < ApplicationController
    require 'csv'
    require 'tempfile'
    before_action :walmart_token
    before_action :walmart_search
    def index
    console
    end 

    private
    def walmart_token
        if cookies[:wm_access_token].nil?
          client_id = Rails.application.credentials.dig(:walmart, :client_id)
          client_secret = Rails.application.credentials.dig(:walmart, :client_secret)
          authorization = "Basic " + Base64.strict_encode64("#{client_id}:#{client_secret}")
          url = URI("https://marketplace.walmartapis.com/v3/token?grant_type=client_credentials")
    
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true
    
          request = Net::HTTP::Post.new(url)
          request["accept"] = 'application/json'
          request["authorization"] = "Basic " + Base64.strict_encode64("#{client_id}:#{client_secret}")
          request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
          request["WM_SVC.NAME"] = "Walmart Marketplace"
          response = http.request(request)
          @walmart = handle_response(response)

          if !@walmart["access_token"].nil?
            cookies[:wm_access_token] = { value: @walmart["access_token"], expires: 14.minute }
          end
        end
    end 

    def walmart_search
        @inventory = Inventory.where(marketplace: "walmart")
        @limit = "1000"
        authorization = cookies[:wm_access_token]
        url = URI("https://marketplace.walmartapis.com/v3/items?limit=#{@limit}")
  
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request["accept"] = 'application/json'
        request["WM_SEC.ACCESS_TOKEN"]= authorization
        request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
        request["WM_SVC.NAME"] = "Walmart Marketplace"
        response = http.request(request)
        @walmart_search  = handle_response(response)
        byebug
        if !@walmart_search.ItemResponse.nil?
            @items = @walmart_search.ItemResponse
            @items.each do |item|
                @wal_inventory = @inventory.where(upc: item.upc)
                p "🔥: " + @wal_inventory.to_s
                if !@wal_inventory.empty?
                    @wal_inventory.each do |inventory|
                        inventory.sku = item.sku
                        inventory.published = item.publishedStatus
                        if item.publishedStatus == "UNPUBLISHED"
                            inventory.unpublished_reason = item.unpublishedReasons.reason
                        end 
                        inventory.active = item.publishedStatus
                        inventory.save
                    end 
                end 
            end
        end 
    end

    def handle_response(response)
        return JSON.parse(response.body, object_class: OpenStruct) if Net::HTTPSuccess
    
        error_message = "API request failed with code #{response.code}: #{response.message}"
        raise ApiError, error_message
        rescue JSON::ParserError
        raise ApiError, "Unable to parse JSON response"
      end

end 