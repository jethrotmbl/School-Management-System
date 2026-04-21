class Teacher < ApplicationRecord
  STATUSES = %w[active inactive on_leave retired].freeze

  belongs_to :department, optional: true
  belongs_to :citizenship, optional: true

  has_many :academic_classes, dependent: :nullify
  has_many :enrollments, -> { distinct }, through: :academic_classes
  has_many :students, -> { distinct }, through: :enrollments
  has_one_attached :profile_photo

  before_validation :assign_employee_number, on: :create

  validates :employee_number, :first_name, :last_name, presence: true
  validates :employee_number, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :ordered, -> { order(:last_name, :first_name) }
  scope :search, ->(term) {
    return all if term.blank?

    wildcard = "%#{term.to_s.strip.downcase}%"
    where(
      "LOWER(employee_number) LIKE :term OR LOWER(first_name) LIKE :term OR LOWER(last_name) LIKE :term OR LOWER(email) LIKE :term",
      term: wildcard
    )
  }

  def full_name
    [first_name, middle_name.presence, last_name, suffix.presence].compact.join(" ")
  end

  private

  def assign_employee_number
    return if employee_number.present?

    self.employee_number = "EMP-#{Time.current.year}-#{SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')}"
  end
end
