class BarangaysController < ApplicationController
  before_action :set_barangay, only: %i[ show edit update destroy ]

  # GET /barangays or /barangays.json
  def index
    @barangays = Barangay.includes(city: { province: { region: :country } })
                         .order(:name)
                         .page(params[:page])
                         .per(10)
  end

  # GET /barangays/1 or /barangays/1.json
  def show
  end

  # GET /barangays/new
  def new
    @barangay = Barangay.new
  end

  # GET /barangays/1/edit
  def edit
  end

  # POST /barangays or /barangays.json
  def create
    @barangay = Barangay.new(barangay_params)

    respond_to do |format|
      if @barangay.save
        format.html { redirect_to @barangay, notice: "Barangay was successfully created." }
        format.json { render :show, status: :created, location: @barangay }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @barangay.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /barangays/1 or /barangays/1.json
  def update
    respond_to do |format|
      if @barangay.update(barangay_params)
        format.html { redirect_to @barangay, notice: "Barangay was successfully updated." }
        format.json { render :show, status: :ok, location: @barangay }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @barangay.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /barangays/1 or /barangays/1.json
  def destroy
    @barangay.destroy

    respond_to do |format|
      format.html { redirect_to barangays_path, status: :see_other, notice: "Barangay was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_barangay
      @barangay = Barangay.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def barangay_params
      params.require(:barangay).permit(:name, :description, :remarks, :city_id)
    end
end
