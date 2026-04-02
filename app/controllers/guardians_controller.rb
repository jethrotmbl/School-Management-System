class GuardiansController < ApplicationController
  before_action :set_guardian, only: %i[show edit update destroy]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def index
    @search_query = params[:q].to_s.strip
    @guardians = Guardian.includes(:citizenship, :city, :students)
                         .search(@search_query)
                         .ordered
                         .page(params[:page])
                         .per(10)
  end

  def search
    index
    @search_mode = true
    render :index
  end

  def show
    @linked_students = @guardian.students.includes(:academic_classes).ordered
  end

  def new
    @guardian = Guardian.new
  end

  def edit
  end

  def create
    @guardian = Guardian.new(guardian_params)

    if @guardian.save
      redirect_to @guardian, notice: "Guardian was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @guardian.update(guardian_params)
      redirect_to @guardian, notice: "Guardian was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @guardian.destroy
    redirect_to guardians_path, status: :see_other, notice: "Guardian was successfully deleted."
  end

  private

  def set_guardian
    @guardian = Guardian.includes(:citizenship, :country, :region, :province, :city, :barangay, :students).find(params[:id])
  end

  def load_form_dependencies
    @citizenships = Citizenship.order(:name)
    @countries = Country.order(:name)
    @regions = Region.order(:name)
    @provinces = Province.order(:name)
    @cities = City.order(:name)
    @barangays = Barangay.order(:name)
    @students = Student.ordered
  end

  def guardian_params
    params.require(:guardian).permit(
      :first_name, :middle_name, :last_name, :relationship_to_student, :email, :phone, :occupation,
      :address_line, :citizenship_id, :country_id, :region_id, :province_id, :city_id, :barangay_id,
      student_ids: []
    )
  end
end
