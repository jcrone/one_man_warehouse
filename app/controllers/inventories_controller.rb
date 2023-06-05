class InventoriesController < ApplicationController
    require 'base64' 
    require 'securerandom'
    before_action :set_upc
    before_action :set_inventory, only: %i[ show edit update destroy ]
    before_action :walmart_token, only: %i[new sync]
    before_action :search_amazon, only: %i[new]
    before_action :search_walmart, only: %i[new]
    before_action :get_walmart_items, only: %i[sync]
    before_action :set_location, only: %i[new show edit update destroy ]
    before_action :set_box, only: %i[new show edit update destroy ]

    # GET /inventories or /inventories.json
    def index
      @hidden = false
      @amazon_link = "https://sellercentral.amazon.com/product-search/search?q="
      @pagy, @inventory = pagy(Inventory.where(["concat_ws(upc, sku, brand, asin, description, marketplace, active) ILIKE ?", "%#{params[:search]}%"]).order(created_at: :desc), items: 100)
      respond_to do |format|
        format.html 
        format.csv {
          if params[:search].nil?
            @inventory = Inventory.all
          end
          send_data @inventory.to_csv(['sku', 'upc', 'asin', 'marketplace','brand', 'description', 'active', 'qty','room','number']), 
          filename: "Inventory-#{Date.today}.csv" 
        }
      end
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

    def sync
      @authorization = cookies[:wm_access_token]
      SyncSkusJob.perform_later(@authorization)
      redirect_to inventories_path, notice: "your inventory has been qued to sync. This may take a few minuntes" 
    end 
  
    # PATCH/PUT /inventories/1 or /inventories/1.json
    def update
      respond_to do |format|
        if @inventory.update(inventory_params)
          format.turbo_stream { redirect_to inventories_path }
          format.html { redirect_to inventories_path, notice: "inventory was successfully updated." }
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
        format.html { redirect_back(fallback_location: root_path) }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_inventory
        @inventory = Inventory.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def inventory_params
        params.require(:inventory).permit(:upc, :sent, :sku, :asin, :description, :location_id, :photo_link, :qty, :box_id, :brand, :marketplace, :active)
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
  
          request = Net::HTTP::Post.new(url)
          request["accept"] = 'application/json'
          request["authorization"] = "Basic " + Base64.strict_encode64("#{client_id}:#{client_secret}")
          request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
          request["WM_SVC.NAME"] = "Walmart Marketplace"
          response = http.request(request)
          @walmart = handle_response(response)

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
            end 
            @walmart_link = "https://seller.walmart.com/item/add-items?search=#{@upc}"
        end
      end

      def get_walmart_items
        @inventory = Inventory.where(marketplace: "walmart")
        @limit = "2000"
        authorization = cookies[:wm_access_token]
        url = URI("https://marketplace.walmartapis.com/v3/items?limit=#{@limit}")
  
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request["accept"] = 'application/json'
        request["WM_SEC.ACCESS_TOKEN"]= authorization
        request["WM_QOS.CORRELATION_ID"] = SecureRandom.uuid
        request["WM_SVC.NAME"] = "Walmart Marketplace"
        response = http.request(request)
        @walmart_items  = handle_response(response)
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
        if !params[:location_id].nil?
         @location = Location.find(params[:location_id])
        elsif !@inventory.nil?
          @location = @inventory.location
        end
      end

      def set_box
        if !params[:location_id].nil?
          @box = Box.find(params[:box_id])
        elsif !@inventory.nil?
          @box = @inventory.box
        end 
      end
  end 
