class PullListPdf < Prawn::Document

    def initialize(orders)
        super()
        @orders = orders
        
        @orders.each do |order|
            move_down 25
            @items = order["items"]
            order_no = order["order_ref"]
            marketplace = order["channel_name"]
            text "Order Number: #{order_no} from #{marketplace}", style: :bold

            @items.each do |item|
                if item["sku"].nil?
                    @inventory = []
                else
                    @inventory = Inventory.where(sku: item["sku"])
                end

              qty= item["quantity"]
                title = item["title"]
                text "ORDERED QTY: #{qty} of #{title}"
                if !@inventory.empty?
                text " Locations: "
                    @inventory.each do |inventory|
                      text  "    * There are #{inventory.qty} @ #{inventory.location.room}-#{inventory.box.number}"
                    end
                else
                    text " * Item doesn't appear to be in this system"
                end
            end 
        end
    end 

end 