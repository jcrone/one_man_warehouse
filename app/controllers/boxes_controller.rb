class BoxesController < ApplicationController
  before_action :set_box, only: %i[ show edit update destroy ]
  before_action :set_location
  before_action :set_box_number, only: %i[ create ]

  # GET /boxes or /boxes.json
  def index
    @boxes = Box.all
  end

  # GET /boxes/1 or /boxes/1.json
  def show
    @amazon_listing = 'https://sellercentral.amazon.com/inventory/?search:'
    @inventory = @box.inventories
    respond_to do |format|
      format.html 
      format.csv {
        send_data @inventory.to_csv(['sku', 'upc', 'asin', 'marketplace','brand', 'description', 'active', 'qty','room','number']), 
        filename: "Inventory-#{Date.today}.csv" 
      }
      format.pdf do 
        @inventory = @inventory.where(marketplace: 'amazon')
        pdf = AsinLablesPdf.new(@inventory)
        send_data pdf.render, filename: "#{@location.room} Box #{@box.box_number} - #{Time.new}.pdf",
                            type: "application/pdf"
      end 
    end
  end

  # GET /boxes/new
  def new
    @box = Box.new
  end

  # GET /boxes/1/edit
  def edit
  end

  # POST /boxes or /boxes.json
  def create
    @box = Box.new(box_params)
    @box.box_number = @box_number
    respond_to do |format|
      if @box.save
        format.html { redirect_to location_box_path(@location, @box), notice: "Box was successfully created." }
        format.json { render :show, status: :created, location: @box }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /boxes/1 or /boxes/1.json
  def update
    respond_to do |format|
      if @box.update(box_params)
        format.html { redirect_to location_box_url(@location, @box), notice: "Box was successfully updated." }
        format.json { render :show, status: :ok, location: @box }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boxes/1 or /boxes/1.json
  def destroy
    @box.destroy

    respond_to do |format|
      format.html { redirect_to location_path(@location), notice: "Box was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_box
      @box = Box.find(params[:id])
    end

    def set_box_number
      boxes = Box.where(location_id: @location.id)
      if boxes.maximum(:box_number).nil?
        @box_number = 1
      else 
        @box_number = boxes.maximum(:box_number) + 1
      end 
    end 

    def set_location
      @location = Location.find(params[:location_id])
    end
    # Only allow a list of trusted parameters through.
    def box_params
      params.require(:box).permit(:number, :location_id, :box_number)
    end
end
