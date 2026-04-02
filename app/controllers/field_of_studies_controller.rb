class FieldOfStudiesController < ApplicationController
  before_action :set_field_of_study, only: %i[show edit update destroy]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def index
    @field_of_studies = FieldOfStudy.includes(:degree, :academic_classes).order(:name).page(params[:page]).per(10)
  end

  def show
    @academic_classes = @field_of_study.academic_classes.includes(:teacher, :school_year).ordered
  end

  def new
    @field_of_study = FieldOfStudy.new
  end

  def edit
  end

  def create
    @field_of_study = FieldOfStudy.new(field_of_study_params)

    if @field_of_study.save
      redirect_to @field_of_study, notice: "Field of study was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @field_of_study.update(field_of_study_params)
      redirect_to @field_of_study, notice: "Field of study was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @field_of_study.destroy
    redirect_to field_of_studies_path, status: :see_other, notice: "Field of study was successfully deleted."
  end

  private

  def set_field_of_study
    @field_of_study = FieldOfStudy.includes(:degree, :academic_classes).find(params[:id])
  end

  def load_form_dependencies
    @degrees = Degree.order(:name)
  end

  def field_of_study_params
    params.require(:field_of_study).permit(:degree_id, :name, :code, :description)
  end
end
