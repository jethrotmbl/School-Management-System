class TeachersController < ApplicationController
  before_action :set_teacher, only: %i[show edit update destroy]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def index
    @search_query = params[:q].to_s.strip
    @teachers = Teacher.includes(:department, :citizenship, academic_classes: :students)
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
    @teacher_classes = @teacher.academic_classes.includes(:school_year, :field_of_study).ordered.limit(10)
    @teacher_students = @teacher.students.includes(:academic_classes).ordered.limit(10)
  end

  def new
    @teacher = Teacher.new(status: "active", hire_date: Date.current)
  end

  def edit
  end

  def create
    @teacher = Teacher.new(teacher_params)

    if @teacher.save
      redirect_to @teacher, notice: "Teacher was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @teacher.update(teacher_params)
      redirect_to @teacher, notice: "Teacher was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @teacher.destroy
    redirect_to teachers_path, status: :see_other, notice: "Teacher was successfully deleted."
  end

  private

  def set_teacher
    @teacher = Teacher.includes(:department, :citizenship, academic_classes: [:school_year, :students]).find(params[:id])
  end

  def load_form_dependencies
    @departments = Department.order(:name)
    @citizenships = Citizenship.order(:name)
  end

  def teacher_params
    params.require(:teacher).permit(
      :employee_number, :first_name, :middle_name, :last_name, :suffix, :email, :phone,
      :status, :specialization, :hire_date, :address_line, :department_id, :citizenship_id,
      :profile_photo
    )
  end
end
