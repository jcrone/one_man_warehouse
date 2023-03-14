class HoursController < ApplicationController
  before_action :set_hour, only: %i[ show edit update destroy ]

  # GET /hours or /hours.json
  def index
    @hours = Hour.all
    @unpaid = @hours.where(status: @hours.statuses[:unpaid]).or(@hours.where(status: @hours.statuses[:processing]))
    @paid = @hours.where(status: @hours.statuses[:paid])
  end

  # GET /hours/1 or /hours/1.json
  def show
  end

  # GET /hours/new
  def new
    @hour = Hour.new
    @employees = Employee.all
  end

  # GET /hours/1/edit
  def edit
  end

  # POST /hours or /hours.json
  def create
    @hour = Hour.new(hour_params)

    respond_to do |format|
      if @hour.save
        format.html { redirect_to hours_path, notice: "#{@hour.employee.name}'s hours were successfully created." }
        format.json { render :show, status: :created, location: @hour }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hours/1 or /hours/1.json
  def update

    if !hour_params[:pay_date].blank? && !@hour.paid? 
      @hour.processing!
      PaidStatusJob.set(wait_until: hour_params[:pay_date].to_datetime ).perform_later(@hour.id)
    end 
    respond_to do |format|
      if @hour.update(hour_params)
        format.html { redirect_to hour_url(@hour), notice: "Hour was successfully updated." }
        format.json { render :show, status: :ok, location: @hour }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hours/1 or /hours/1.json
  def destroy
    @hour.destroy

    respond_to do |format|
      format.html { redirect_to hours_url, notice: "Hour was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hour
      @hour = Hour.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hour_params
      params.require(:hour).permit(:employee_id, :hours, :start_date, :end_date, :pay_date, :status)
    end
end
