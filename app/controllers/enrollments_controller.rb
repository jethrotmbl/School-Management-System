class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[show edit update destroy]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def index
    @enrollments = Enrollment.includes(:student, :academic_class, :school_year, :enrollment_period)
                             .recent_first
                             .page(params[:page])
                             .per(10)
  end

  def show
  end

  def new
    @enrollment = Enrollment.new(enrolled_on: Date.current, status: "enrolled")
  end

  def edit
  end

  def create
    @enrollment = Enrollment.new(enrollment_params)

    if @enrollment.save
      redirect_to @enrollment, notice: "Enrollment was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @enrollment.update(enrollment_params)
      redirect_to @enrollment, notice: "Enrollment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @enrollment.destroy
    redirect_to enrollments_path, status: :see_other, notice: "Enrollment was successfully deleted."
  end

  private

  def set_enrollment
    @enrollment = Enrollment.includes(:student, :academic_class, :school_year, :enrollment_period).find(params[:id])
  end

  def load_form_dependencies
    @students = Student.ordered
    @academic_classes = AcademicClass.includes(:teacher, :school_year).ordered
    @school_years = SchoolYear.recent_first
    @enrollment_periods = EnrollmentPeriod.includes(:school_year).order(:starts_on)
  end

  def enrollment_params
    params.require(:enrollment).permit(
      :student_id, :academic_class_id, :school_year_id, :enrollment_period_id, :status,
      :enrolled_on, :final_grade, :remarks
    )
  end
end
