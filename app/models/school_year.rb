class SchoolYear < ApplicationRecord
  STATUSES = %w[planned open closed archived].freeze
  DEFAULT_TERM_NAMES = ["1st Semester", "2nd Semester", "Summer Term"].freeze

  has_many :enrollment_periods, dependent: :destroy
  has_many :academic_classes, dependent: :destroy
  has_many :enrollments, dependent: :destroy

  after_create :ensure_default_enrollment_periods!

  validates :name, :starts_on, :ends_on, presence: true
  validates :name, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :recent_first, -> { order(starts_on: :desc, name: :desc) }

  def open!
    update!(status: "open", opened_at: Time.current)
  end

  def date_range
    return "-" if starts_on.blank? || ends_on.blank?

    "#{starts_on.strftime('%b %d, %Y')} - #{ends_on.strftime('%b %d, %Y')}"
  end

  def ensure_default_enrollment_periods!
    return if starts_on.blank? || ends_on.blank?
    return if enrollment_periods.count >= DEFAULT_TERM_NAMES.length

    default_term_ranges.each_with_index do |range, index|
      break if enrollment_periods.count >= DEFAULT_TERM_NAMES.length

      enrollment_periods.find_or_create_by(name: DEFAULT_TERM_NAMES[index]) do |period|
        period.starts_on = range[:starts_on]
        period.ends_on = range[:ends_on]
        period.status = "planning"
      end
    end
  end

  def default_term_ranges
    total_days = [(ends_on - starts_on).to_i, 0].max
    first_end = [starts_on + (total_days / 3), ends_on].min
    second_start = [first_end + 1, ends_on].min
    second_end = [starts_on + ((total_days * 2) / 3), ends_on].min
    second_end = second_start if second_end < second_start
    third_start = [second_end + 1, ends_on].min

    [
      { starts_on: starts_on, ends_on: first_end },
      { starts_on: second_start, ends_on: second_end },
      { starts_on: third_start, ends_on: ends_on }
    ]
  end
end
