class EnrollmentPeriod < ApplicationRecord
  STATUSES = %w[upcoming open closed].freeze

  belongs_to :school_year
  has_many :academic_classes, dependent: :nullify
  has_many :enrollments, dependent: :nullify

  validates :name, :starts_on, :ends_on, presence: true
  validates :name, uniqueness: { scope: :school_year_id }
  validates :status, inclusion: { in: STATUSES }
end
