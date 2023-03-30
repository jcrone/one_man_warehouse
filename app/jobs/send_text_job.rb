class SendTextJob < ApplicationJob
    queue_as :default
  
    def perform(order)
        @order_ref = order["order_ref"]
        @channel_name = order["channel_name"]
        @shipping = order["requested_shipping_service"]
        rachel_number = '16199173432'
        jamie_number = '16195080039'
        TwilioClient.new.send_text(@order_ref, @channel_name, @shipping, rachel_number)
        TwilioClient.new.send_text(@order_ref, @channel_name, @shipping, jamie_number)
    end
  end