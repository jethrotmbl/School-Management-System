class DepartmentsController < ApplicationController
  before_action :set_department, only: %i[show edit update destroy]

  def index
    @departments = Department.includes(:teachers).order(:name).page(params[:page]).per(10)
  end

  def show
    @teachers = @department.teachers.ordered
  end

  def new
    @department = Department.new
  end

  def edit
  end

  def create
    @department = Department.new(department_params)

    if @department.save
      redirect_to @department, notice: "Department was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @department.update(department_params)
      redirect_to @department, notice: "Department was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @department.destroy
    redirect_to departments_path, status: :see_other, notice: "Department was successfully deleted."
  end

  private

  def set_department
    @department = Department.includes(:teachers).find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :code, :description)
  end
end
