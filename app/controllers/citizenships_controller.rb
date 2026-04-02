class CitizenshipsController < ApplicationController
  before_action :set_citizenship, only: %i[show edit update destroy]

  def index
    @citizenships = Citizenship.includes(:students, :teachers, :guardians).order(:name).page(params[:page]).per(10)
  end

  def show
  end

  def new
    @citizenship = Citizenship.new
  end

  def edit
  end

  def create
    @citizenship = Citizenship.new(citizenship_params)

    if @citizenship.save
      redirect_to @citizenship, notice: "Citizenship was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @citizenship.update(citizenship_params)
      redirect_to @citizenship, notice: "Citizenship was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @citizenship.destroy
    redirect_to citizenships_path, status: :see_other, notice: "Citizenship was successfully deleted."
  end

  private

  def set_citizenship
    @citizenship = Citizenship.includes(:students, :teachers, :guardians).find(params[:id])
  end

  def citizenship_params
    params.require(:citizenship).permit(:name, :description)
  end
end
