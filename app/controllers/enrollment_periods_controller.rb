class EnrollmentPeriodsController < ApplicationController
  before_action :set_enrollment_period, only: %i[show edit update destroy set_current]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def index
    @enrollment_periods = EnrollmentPeriod.includes(:school_year, :academic_classes, :enrollments)
                        .order(starts_on: :desc, name: :asc)
                                          .page(params[:page])
                                          .per(10)
  end

  def show
    @academic_classes = @enrollment_period.academic_classes.includes(:teacher, :school_year).ordered
    @enrollments = @enrollment_period.enrollments.includes(:student, :academic_class).recent_first
  end

  def new
    @enrollment_period = EnrollmentPeriod.new(status: "planning")
  end

  def edit
  end

  def create
    @enrollment_period = EnrollmentPeriod.new(enrollment_period_params)

    if @enrollment_period.save
      redirect_to @enrollment_period, notice: "Enrollment period was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @enrollment_period.update(enrollment_period_params)
      redirect_to @enrollment_period, notice: "Enrollment period was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @enrollment_period.destroy
    redirect_to enrollment_periods_path, status: :see_other, notice: "Enrollment period was successfully deleted."
  end

  def set_current
    @enrollment_period.set_current!
    redirect_to school_year_path(@enrollment_period.school_year), notice: "Current term updated successfully."
  rescue ActiveRecord::RecordInvalid
    redirect_to school_year_path(@enrollment_period.school_year), alert: @enrollment_period.errors.full_messages.to_sentence.presence || "Unable to set current term."
  end

  private

  def set_enrollment_period
    @enrollment_period = EnrollmentPeriod.includes(:school_year, :academic_classes, :enrollments).find(params[:id])
  end

  def load_form_dependencies
    @school_years = SchoolYear.recent_first
  end

  def enrollment_period_params
    params.require(:enrollment_period).permit(:school_year_id, :name, :starts_on, :ends_on, :status, :description)
  end
end
