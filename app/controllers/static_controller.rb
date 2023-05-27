class StaticController < ApplicationController
    layout "welcome", only: [:welcome]
    before_action :set_sellbrite, only:[:dashboard]


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

    def handle_response(response)
        return JSON.parse(response.body) if Net::HTTPSuccess
    
        error_message = "API request failed with code #{response.code}: #{response.message}"
        raise ApiError, error_message
      rescue JSON::ParserError
        raise ApiError, "Unable to parse JSON response"
    end

end