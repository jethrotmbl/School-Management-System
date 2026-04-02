class Enrollment < ApplicationRecord
  STATUSES = %w[enrolled completed dropped cancelled].freeze

  belongs_to :student
  belongs_to :academic_class
  belongs_to :school_year
  belongs_to :enrollment_period, optional: true

  validates :student, :academic_class, :school_year, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :student_id, uniqueness: { scope: [:academic_class_id, :school_year_id] }

  scope :recent_first, -> { order(enrolled_on: :desc, created_at: :desc) }
end
