class SchoolYearsController < ApplicationController
  before_action :set_school_year, only: %i[show edit update destroy open]

  def index
    @school_years = SchoolYear.includes(:enrollment_periods, :academic_classes, :enrollments)
                              .recent_first
                              .page(params[:page])
                              .per(10)
  end

  def show
    @enrollment_periods = @school_year.enrollment_periods.order(:starts_on)
    @academic_classes = @school_year.academic_classes.includes(:teacher).ordered
    @enrollments = @school_year.enrollments.includes(:student, :academic_class).recent_first.limit(10)
  end

  def new
    status = params[:open_now].present? ? "open" : "planned"
    @school_year = SchoolYear.new(status: status)
  end

  def edit
  end

  def create
    @school_year = SchoolYear.new(school_year_params)
    @school_year.opened_at = Time.current if @school_year.status == "open" && @school_year.opened_at.blank?

    if @school_year.save
      redirect_to @school_year, notice: "School year was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @school_year.update(school_year_params)
      redirect_to @school_year, notice: "School year was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def open
    @school_year.open!
    redirect_to @school_year, notice: "School year is now open."
  end

  def destroy
    @school_year.destroy
    redirect_to school_years_path, status: :see_other, notice: "School year was successfully deleted."
  end

  private

  def set_school_year
    @school_year = SchoolYear.find(params[:id])
  end

  def school_year_params
    params.require(:school_year).permit(:name, :starts_on, :ends_on, :status, :description)
  end
end
