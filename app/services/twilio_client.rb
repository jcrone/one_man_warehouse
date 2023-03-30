class TwilioClient
    attr_reader :client

    def initialize
      @client = Twilio::REST::Client.new account_sid, auth_token
      last = Message.count
      id = rand(1..last)
      @message = Message.find(id)
    end

    def send_text(order_ref, channel, shipping, to_number)
      @client.messages.create(
        from: phone_number,
        to: to_number,
        body: "#{@message.message} #{order_ref} its #{shipping} from #{channel} !SEND IT!"
      )
    end 
  
  private
    def account_sid
        Rails.application.credentials.twilio[:account_id] 
    end
    
    def auth_token
        Rails.application.credentials.twilio[:auth_token] 
    end 

    def phone_number
      Rails.application.credentials.twilio[:phone_number] 
    end

end