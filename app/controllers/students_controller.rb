class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def index
    @search_query = params[:q].to_s.strip
    @students = Student.includes(:citizenship, :city, :guardians, academic_classes: :teacher)
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
    @current_enrollments = @student.enrollments.includes(academic_class: [:teacher, :school_year]).recent_first.limit(10)
    @linked_student_guardians = @student.student_guardians.includes(:guardian)
                                      .joins(:guardian)
                                      .merge(Guardian.ordered)
    @linked_teachers = @student.teachers.includes(:department).order(:last_name, :first_name)
  end

  def new
    @student = Student.new(status: "active")
  end

  def edit
  end

  def create
    @student = Student.new(student_params)

    if @student.save
      redirect_to @student, notice: "Student was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @student.update(student_params)
      redirect_to @student, notice: "Student was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, status: :see_other, notice: "Student was successfully deleted."
  end

  private

  def set_student
    @student = Student.includes(:citizenship, :country, :region, :province, :city, :barangay, :guardians, :teachers, student_guardians: :guardian).find(params[:id])
  end

  def load_form_dependencies
    @citizenships = Citizenship.order(:name)
    @countries = Country.order(:name)
    @regions = Region.order(:name)
    @provinces = Province.order(:name)
    @cities = City.order(:name)
    @barangays = Barangay.order(:name)
    @guardians = Guardian.ordered
  end

  def student_params
    params.require(:student).permit(
      :first_name, :middle_name, :last_name, :suffix, :birth_date, :gender, :email, :phone, :status,
      :address_line, :citizenship_id, :country_id, :region_id, :province_id, :city_id, :barangay_id,
      guardian_ids: []
    )
  end
end
