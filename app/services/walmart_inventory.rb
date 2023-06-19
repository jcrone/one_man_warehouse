class WalmartInventory
    attr_reader :client
    require 'net/http'
    require 'securerandom'
    require 'base64'

    def initialize
        @skus = Inventory.where(marketplace: 'walmart').where.not(sku: nil).distinct.pluck(:sku)
    end 

    def add_walmart_skus(authorization)        
        @authorization = authorization
        @skus.each do |sku|
            url = URI("https://marketplace.walmartapis.com/v3/inventory?sku=#{sku}")
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            request = Net::HTTP::Get.new(url)
            request["accept"] = 'application/json'
            request["WM_SEC.ACCESS_TOKEN"]= @authorization
            request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
            request["WM_SVC.NAME"] = "Walmart Marketplace"
            response = http.request(request)          
            inventory_response = handle_response(response)
            p "🔥 : #{inventory_response}"
            if !inventory_response.quantity.nil?
                inventories = Inventory.where(sku: sku)
                inventories.each do |inventory|
                    inventory.amz_qty = inventory_response.quantity.amount
                    inventory.save
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