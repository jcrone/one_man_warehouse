class AsinLablesPdf < Prawn::Document
    require 'barby'
    require 'barby/barcode/code_128'
    require 'barby/outputter/png_outputter'

    def initialize(amazon_inventory)
      super(:page_size => [288, 144],:top_margin => 0,:bottom_margin => 0, :left_margin => 0, :right_margin => 0)
      @amazon_inventory = amazon_inventory
      @total = @amazon_inventory.sum(:qty)
      inventory_number
    end

    def inventory_number
        page = 1
        @amazon_inventory.each do |amazon_inventory|
          
          for i in 1..amazon_inventory.qty
            asin = Barby::Code128B.new(amazon_inventory.asin)
            barcode = Barby::PngOutputter.new(asin)
            barcode.height = 50
            File.open("tmp/barcode.png", 'wb'){|f| f.write barcode.to_png }
                text "\n"
                text "Brand: #{amazon_inventory.brand}", align: :center
                text "#{amazon_inventory.description}", align: :center
        
                image "#{Rails.root.to_s}/tmp/barcode.png", width:120, position: :center
                text "#{amazon_inventory.asin}", size:10, align: :center
        

                if page < @total
                start_new_page
                page += 1
                end
          end
        end
    end



end 