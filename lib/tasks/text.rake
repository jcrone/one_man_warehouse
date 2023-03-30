task texting: :environment do 
    url = URI("https://api.sellbrite.com/v1/orders?page=1&limit=100&sb_status=open&sb_payment_status=all")
       
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["authorization"] = Rails.application.credentials.dig(:sellbrite, :basic_code)
    
    response = http.request(request)
    @orders = JSON.parse(response.body)
    
    @orders.each do |order|
        order["items"].each do |item|
            if order["requested_shipping_service"] == "Second Day" || item["Shipping Method"] == "Expedited"  
                @order_text = OrderText.find_by(order_ref: order["order_ref"])
                if @order_text.nil? 
                    order_text = OrderText.new
                    order_text.order_ref = order["order_ref"]
                    if order_text.save
                        SendTextJob.perform_later(order)
                    end 
                end
            end 
        end 
    end 
end 
