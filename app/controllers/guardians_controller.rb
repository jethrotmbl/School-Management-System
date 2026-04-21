class GuardiansController < ApplicationController
  before_action :set_guardian, only: %i[show edit update destroy]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def index
    @search_query = params[:q].to_s.strip
    @guardians = Guardian.includes(:citizenship, :city, :students, student_guardians: :student)
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
    @linked_student_guardians = @guardian.student_guardians.includes(:student)
                                      .joins(:student)
                                      .merge(Student.ordered)
  end

  def new
    @guardian = Guardian.new
    build_student_link_inputs
  end

  def edit
    build_student_link_inputs
  end

  def create
    @guardian = Guardian.new(guardian_params)

    if save_guardian_with_student_links
      redirect_to @guardian, notice: "Guardian was successfully created."
    else
      build_student_link_inputs
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @guardian.assign_attributes(guardian_params)

    if save_guardian_with_student_links
      redirect_to @guardian, notice: "Guardian was successfully updated."
    else
      build_student_link_inputs
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @guardian.destroy
    redirect_to guardians_path, status: :see_other, notice: "Guardian was successfully deleted."
  end

  private

  def set_guardian
    @guardian = Guardian.includes(:citizenship, :country, :region, :province, :city, :barangay, :students, student_guardians: :student).find(params[:id])
  end

  def load_form_dependencies
    @citizenships = Citizenship.order(:name)
    @countries = Country.order(:name)
    @regions = Region.order(:name)
    @provinces = Province.order(:name)
    @cities = City.order(:name)
    @barangays = Barangay.order(:name)
    @students = Student.ordered
  end

  def guardian_params
    params.require(:guardian).permit(
      :first_name, :middle_name, :last_name, :email, :phone, :occupation,
      :address_line, :citizenship_id, :country_id, :region_id, :province_id, :city_id, :barangay_id,
      :profile_photo
    )
  end

  def save_guardian_with_student_links
    saved = false

    Guardian.transaction do
      unless @guardian.save
        raise ActiveRecord::Rollback
      end

      sync_student_links!
      saved = true
    rescue ActiveRecord::RecordInvalid => error
      message = error.record&.errors&.full_messages&.to_sentence.presence || "Unable to save linked students."
      @guardian.errors.add(:base, message)
      raise ActiveRecord::Rollback
    end

    saved
  end

  def sync_student_links!
    submitted_links = params.dig(:guardian, :student_links) || {}
    selected_student_ids = []

    submitted_links.each do |student_id, attributes|
      attributes = normalize_student_link_attributes(attributes)
      selected_value = attributes[:selected] || attributes["selected"]
      next unless ActiveModel::Type::Boolean.new.cast(selected_value)

      parsed_student_id = student_id.to_i
      next if parsed_student_id <= 0

      relationship_value = attributes[:relationship] || attributes["relationship"]
      student_guardian = @guardian.student_guardians.find_or_initialize_by(student_id: parsed_student_id)
      student_guardian.relationship_to_student = relationship_value.to_s.strip.presence
      student_guardian.save!
      selected_student_ids << parsed_student_id
    end

    @guardian.student_guardians.where.not(student_id: selected_student_ids).destroy_all
  end

  def build_student_link_inputs
    submitted_links = params.dig(:guardian, :student_links)

    @student_link_inputs = if submitted_links.present?
      submitted_links.each_with_object({}) do |(student_id, attributes), result|
        attributes = normalize_student_link_attributes(attributes)
        selected_value = attributes[:selected] || attributes["selected"]
        relationship_value = attributes[:relationship] || attributes["relationship"]

        result[student_id.to_i] = {
          selected: ActiveModel::Type::Boolean.new.cast(selected_value),
          relationship: relationship_value.to_s
        }
      end
    else
      @guardian.student_guardians.each_with_object({}) do |student_guardian, result|
        result[student_guardian.student_id] = {
          selected: true,
          relationship: student_guardian.relationship_to_student.to_s
        }
      end
    end
  end

  def normalize_student_link_attributes(attributes)
    return {} unless attributes

    if attributes.respond_to?(:permit)
      attributes.permit(:selected, :relationship).to_h
    elsif attributes.respond_to?(:to_h)
      attributes.to_h
    else
      {}
    end
  end
end
