class AcademicClassesController < ApplicationController
  before_action :set_academic_class, only: %i[show edit update destroy]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def index
    @search_query = params[:q].to_s.strip
    @academic_classes = AcademicClass.includes(:school_year, :teacher, :degree, :field_of_study, :students)
                                     .search(@search_query)
                                     .ordered
                                     .page(params[:page])
                                     .per(10)
  end

  def show
    @enrollments = @academic_class.enrollments.includes(:student).recent_first
  end

  def new
    @academic_class = AcademicClass.new(status: "open")
  end

  def edit
  end

  def create
    @academic_class = AcademicClass.new(academic_class_params)

    if @academic_class.save
      redirect_to @academic_class, notice: "Class was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @academic_class.update(academic_class_params)
      redirect_to @academic_class, notice: "Class was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @academic_class.destroy
    redirect_to academic_classes_path, status: :see_other, notice: "Class was successfully deleted."
  end

  private

  def set_academic_class
    @academic_class = AcademicClass.includes(:school_year, :enrollment_period, :teacher, :degree, :field_of_study, enrollments: :student).find(params[:id])
  end

  def load_form_dependencies
    @school_years = SchoolYear.recent_first
    @enrollment_periods = EnrollmentPeriod.includes(:school_year).order(:starts_on)
    @degrees = Degree.order(:name)
    @field_of_studies = FieldOfStudy.includes(:degree).order(:name)
    @teachers = Teacher.includes(:department).ordered
  end

  def academic_class_params
    params.require(:academic_class).permit(
      :school_year_id, :enrollment_period_id, :degree_id, :field_of_study_id, :teacher_id,
      :class_code, :title, :units, :section, :room, :schedule, :status, :description
    )
  end
end
