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

                if qty.to_i > 1 
                    icon "<icon color='D11D1D'>fas-exclamation-circle</icon> <icon color='fcba03'>fas-beer</icon> <icon color='fcba03'>fas-beer</icon> ORDERED QTY: #{qty} of #{title}", inline_format: true
                else
                    text "ORDERED QTY: #{qty} of #{title}"
                end
                if !@inventory.empty?
                    formatted_text([{:text=>"SEARCH: #{@inventory.last.upc}", :link=>"http://onemanwarehouse.com/inventories?search=#{@inventory.last.upc}", :color=>"0000ee"}])
                    text "UPC: #{@inventory.last.upc}"
                    text "ASIN: #{@inventory.last.asin}   SKU: #{@inventory.last.sku}"
                text " Locations: "
                    @inventory.each do |inventory|
                        if inventory.qty > 0
                          text  "    * In Stock: <b>#{inventory.qty} @ <u>#{inventory.location.room}-#{inventory.box.box_number}</b></u>", inline_format: true
                        else 
                          text  "    * Out of Stock: <b>#{inventory.qty} last seen @ <u>#{inventory.location.room}-#{inventory.box.box_number}</b></u>", inline_format: true
                        end
                    end
                else
                    text " * Item doesn't appear to be in this system"
                end
            end 
        end
    end 

end 