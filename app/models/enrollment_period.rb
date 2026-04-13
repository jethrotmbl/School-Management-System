class EnrollmentPeriod < ApplicationRecord
  STATUSES = %w[planning active completed].freeze

  belongs_to :school_year
  has_many :academic_classes, dependent: :nullify
  has_many :enrollments, dependent: :nullify

  validates :name, :starts_on, :ends_on, presence: true
  validates :name, uniqueness: { scope: :school_year_id }
  validates :status, inclusion: { in: STATUSES }
  validates :status, uniqueness: { scope: :school_year_id, message: "can only have one Active term per school year" }, if: :active?
  validate :term_limit_per_school_year, on: :create

  scope :ordered, -> { order(:starts_on, :name) }

  before_validation :normalize_legacy_status_values
  before_validation :complete_other_active_terms, if: :will_become_active?

  def active?
    status == "active"
  end

  def set_current!
    transaction do
      school_year.enrollment_periods.where(status: "active").where.not(id: id).update_all(status: "completed", updated_at: Time.current)
      update!(status: "active")
    end
  end

  private

  def normalize_legacy_status_values
    self.status = case status
                  when "upcoming" then "planning"
                  when "open" then "active"
                  when "closed" then "completed"
                  else status
                  end
  end

  def will_become_active?
    school_year_id.present? && status == "active"
  end

  def complete_other_active_terms
    school_year.enrollment_periods.where(status: "active").where.not(id: id).update_all(status: "completed", updated_at: Time.current)
  end

  def term_limit_per_school_year
    return unless school_year_id.present?
    return unless school_year.enrollment_periods.count >= 3

    errors.add(:base, "Each school year can only have three terms.")
  end
end
