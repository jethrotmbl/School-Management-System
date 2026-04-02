class DegreesController < ApplicationController
  before_action :set_degree, only: %i[show edit update destroy]

  def index
    @degrees = Degree.includes(:field_of_studies, :academic_classes).order(:name).page(params[:page]).per(10)
  end

  def show
    @field_of_studies = @degree.field_of_studies.order(:name)
    @academic_classes = @degree.academic_classes.includes(:teacher, :school_year).ordered
  end

  def new
    @degree = Degree.new
  end

  def edit
  end

  def create
    @degree = Degree.new(degree_params)

    if @degree.save
      redirect_to @degree, notice: "Degree was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @degree.update(degree_params)
      redirect_to @degree, notice: "Degree was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @degree.destroy
    redirect_to degrees_path, status: :see_other, notice: "Degree was successfully deleted."
  end

  private

  def set_degree
    @degree = Degree.includes(:field_of_studies, :academic_classes).find(params[:id])
  end

  def degree_params
    params.require(:degree).permit(:name, :code, :description)
  end
end
