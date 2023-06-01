class OrdersController < ApplicationController
    require 'csv'
    require 'tempfile'
    before_action :set_sellbrite

    def index
        respond_to do |format|
            format.html
            format.pdf do
                pdf = PullListPdf.new(@orders)
                send_data pdf.render, filename: "pull_list#{Time.new}.pdf",
                                    type: "application/pdf"
            end

        end
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