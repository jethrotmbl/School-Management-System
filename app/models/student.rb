class Student < ApplicationRecord
  STATUSES = %w[active inactive alumni pending].freeze

  belongs_to :citizenship, optional: true
  belongs_to :country, optional: true
  belongs_to :region, optional: true
  belongs_to :province, optional: true
  belongs_to :city, optional: true
  belongs_to :barangay, optional: true

  has_many :student_guardians, dependent: :destroy
  has_many :guardians, through: :student_guardians
  has_many :enrollments, dependent: :destroy
  has_many :academic_classes, through: :enrollments
  has_many :teachers, -> { distinct }, through: :academic_classes
  has_one_attached :profile_photo

  before_validation :assign_student_number, on: :create

  validates :student_number, :first_name, :last_name, presence: true
  validates :student_number, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :ordered, -> { order(:last_name, :first_name) }
  scope :search, lambda { |term|
    return all if term.blank?

    wildcard = "%#{term.to_s.strip.downcase}%"
    where(
      "LOWER(student_number) LIKE :term OR LOWER(first_name) LIKE :term OR LOWER(last_name) LIKE :term OR LOWER(email) LIKE :term",
      term: wildcard
    )
  }

  def full_name
    given_names = [first_name, middle_name.presence].compact.join(" ").strip
    base_name = [last_name, given_names.presence].compact.join(", ")

    [base_name, suffix.presence].compact.join(" ")
  end

  def location_name
    [barangay&.name, city&.name, province&.name, region&.name, country&.name].compact.join(", ")
  end

  private

  def assign_student_number
    self.student_number = StudentNumberSequence.generate_next_number! if student_number.blank?
  end
end
