class AcademicClass < ApplicationRecord
  STATUSES = %w[open ongoing closed archived].freeze

  belongs_to :school_year
  belongs_to :enrollment_period, optional: true
  belongs_to :degree, optional: true
  belongs_to :field_of_study, optional: true
  belongs_to :teacher, optional: true

  has_many :enrollments, dependent: :destroy
  has_many :students, -> { distinct }, through: :enrollments

  validates :class_code, :title, :school_year, presence: true
  validates :class_code, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :ordered, -> { order(:title, :class_code) }
  scope :search, lambda { |term|
    return all if term.blank?

    wildcard = "%#{term.to_s.strip.downcase}%"
    where(
      "LOWER(class_code) LIKE :term OR LOWER(title) LIKE :term OR LOWER(section) LIKE :term OR LOWER(room) LIKE :term",
      term: wildcard
    )
  }

  def display_name
    [class_code, title, section.presence].compact.join(" - ")
  end
end
