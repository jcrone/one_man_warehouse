class InventoriesController < ApplicationController
    require 'base64' 
    require 'securerandom'
    before_action :set_upc
    before_action :set_inventory, only: %i[ show edit update destroy ]
    before_action :walmart_token, only: %i[new]
    before_action :search_amazon, only: %i[new]
    before_action :search_walmart, only: %i[new]
    before_action :set_location, only: %i[new show edit update destroy ]
    before_action :set_box, only: %i[new show edit update destroy ]

    # GET /inventories or /inventories.json
    def index
      @pagy, @inventory = pagy(Inventory.where(["concat_ws(upc, sku, brand, asin, description, marketplace) ILIKE ?", "%#{params[:search]}%"]), items: 100)
    end
  
    # GET /inventories/1 or /inventories/1.json
    def show
    end
  
    # GET /inventories/new
    def new
      @inventory = Inventory.new
    end
  
    # GET /inventories/1/edit
    def edit
    end
  
    # POST /inventories or /inventories.json
    def create
      @inventory = Inventory.new(inventory_params)
      respond_to do |format|
        if @inventory.save
          format.html { redirect_to new_location_box_inventory_url(@inventory.location_id, @inventory.box_id), notice: "inventory was successfully created." }
          format.json { render :show, status: :created, inventory: @inventory }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @inventory.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /inventories/1 or /inventories/1.json
    def update
      respond_to do |format|
        if @inventory.update(inventory_params)
          format.html { redirect_to location_box_inventory_path(@inventory.location_id, @inventory.box_id), notice: "inventory was successfully updated." }
          format.json { render :show, status: :ok, inventory: @inventory }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @inventory.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /inventories/1 or /inventories/1.json
    def destroy
      @inventory.destroy
       respond_to do |format|
        format.html { redirect_to inventories_url, notice: "inventory was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_inventory
        @inventory = inventory.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def inventory_params
        params.require(:inventory).permit(:upc, :sku, :asin, :description, :location_id, :photo_link, :qty, :box_id, :brand, :marketplace)
      end

      def set_upc
        @upc = params[:upc]
      end 

      def walmart_token
        if cookies[:wm_access_token].nil?
          client_id = Rails.application.credentials.dig(:walmart, :client_id)
          client_secret = Rails.application.credentials.dig(:walmart, :client_secret)
          authorization = "Basic " + Base64.strict_encode64("#{client_id}:#{client_secret}")
          url = URI("https://marketplace.walmartapis.com/v3/token?grant_type=client_credentials")
  
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true
  
          p "🔥: "  + client_id + " : " + client_secret + " : "+ authorization
          request = Net::HTTP::Post.new(url)
          request["accept"] = 'application/json'
          request["authorization"] = "Basic " + Base64.strict_encode64("#{client_id}:#{client_secret}")
          request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
          request["WM_SVC.NAME"] = "Walmart Marketplace"
          response = http.request(request)
          @walmart = handle_response(response)
          p "🔥: " + @walmart.to_s
          if !@walmart["access_token"].nil?
            cookies[:wm_access_token] = { value: @walmart["access_token"], expires: 14.minute }
          end
        end
      end 

      def search_walmart
        if !@upc.nil?
            authorization = cookies[:wm_access_token]
            url = URI("https://marketplace.walmartapis.com/v3/items/walmart/search?upc=#{@upc}")
  
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            request = Net::HTTP::Get.new(url)
            request["accept"] = 'application/json'
            request["WM_SEC.ACCESS_TOKEN"]= authorization
            request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
            request["WM_SVC.NAME"] = "Walmart Marketplace"
            response = http.request(request)
            @walmart_search  = handle_response(response)

            if !@walmart_search.items.nil?
              @walmart_search_photo = @walmart_search.items[0].images[0].url
              @walmart_search_brand = @walmart_search.items[0].brand
              @walmart_search_description = @walmart_search.items[0].description
              @walmart_link = "https://seller.walmart.com/item/add-items?search=#{@upc}"
            end 
        end
      end

      def search_amazon
        if !@upc.nil?
          api_instance = AmzSpApi::CatalogItemsApiModel::CatalogApi.new(AmzSpApi::SpApiClient.new)
          marketplace_ids = ['ATVPDKIKX0DER']# Array<String> | A comma-delimited list of Amazon marketplace identifiers for the request.
          opts = { 
            identifiers: [@upc],
            identifiers_type: 'UPC', # String | Type of product identifiers to search the Amazon catalog for. **Note:** Required when `identifiers` are provided.
            included_data: ['summaries','images']
          }

          begin
            @amazon_search = api_instance.search_catalog_items(marketplace_ids, opts)
            p @amazon_search
          rescue AmzSpApi::CatalogItemsApiModel::ApiError => e
            puts "Exception when calling CatalogApi->search_catalog_items: #{e}"
          end
          if @amazon_search.number_of_results > 0
            @amazon_search_asin = @amazon_search.items.first[:asin]
            @amazon_search_photo = @amazon_search.items.first[:images].first[:images][1][:link]
            @amazon_search_size  = @amazon_search.items.first[:summaries].first[:size]
            @amazon_search_brand  = @amazon_search.items.first[:summaries].first[:brand]
            @amazon_search_color  = @amazon_search.items.first[:summaries].first[:color]
            @amazon_search_itemName  = @amazon_search.items.first[:summaries].first[:itemName]
            @amazon_link = "https://sellercentral.amazon.com/product-search/search?q=#{@upc}"
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

      def set_location
        @location = Location.find(params[:location_id])
      end

      def set_box
        @box = Box.find(params[:box_id])
      end
  end 