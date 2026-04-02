class SchoolYear < ApplicationRecord
  STATUSES = %w[planned open closed archived].freeze

  has_many :enrollment_periods, dependent: :destroy
  has_many :academic_classes, dependent: :destroy
  has_many :enrollments, dependent: :destroy

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
end
