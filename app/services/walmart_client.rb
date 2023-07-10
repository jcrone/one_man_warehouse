class WalmartClient
    attr_reader :client
    require 'net/http'
    require 'securerandom'
    require 'base64'

    def initialize
        @inventory = Inventory.where(marketplace: "walmart")
    end 

    def add_walmart_skus(authorization)        
        # syncing = Sync.find(2)
        # syncing.pending!
        @limit = "1000"
        @authorization = authorization
        url = URI("https://marketplace.walmartapis.com/v3/items?limit=#{@limit}")
  
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request["accept"] = 'application/json'
        request["WM_SEC.ACCESS_TOKEN"]= @authorization
        request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
        request["WM_SVC.NAME"] = "Walmart Marketplace"
        response = http.request(request)
        @walmart_search  = handle_response(response)
        # p "🔥 : #{@walmart_search}"
        if !@walmart_search.ItemResponse.nil?
            @items = @walmart_search.ItemResponse
           
            @items.each do |item|
                @wal_inventory = @inventory.where(upc: item.upc)
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
            @inventory = Inventory.where(marketplace: "walmart", active: "unknown")
            if !@inventory.blank?
                @inventory.update_all(active: "NOT-LISTED")
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