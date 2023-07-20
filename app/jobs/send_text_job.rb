class SendTextJob < ApplicationJob
    queue_as :default
  
    def perform(order)
        @order_ref = order["order_ref"]
        @channel_name = order["channel_name"]
        @shipping = order["requested_shipping_service"]
        primary_number = Rails.application.credentials.phone_number[:primary] 
        secondary_number = Rails.application.credentials.phone_number[:secondary] 
        TwilioClient.new.send_text(@order_ref, @channel_name, @shipping, primary_number)
        TwilioClient.new.send_text(@order_ref, @channel_name, @shipping, secondary_number)
    end
  end