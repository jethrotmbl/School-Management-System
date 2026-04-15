class Guardian < ApplicationRecord
  belongs_to :citizenship, optional: true
  belongs_to :country, optional: true
  belongs_to :region, optional: true
  belongs_to :province, optional: true
  belongs_to :city, optional: true
  belongs_to :barangay, optional: true

  has_many :student_guardians, dependent: :destroy
  has_many :students, through: :student_guardians
  has_one_attached :profile_photo

  validates :first_name, :last_name, presence: true

  scope :ordered, -> { order(:last_name, :first_name) }
  scope :search, lambda { |term|
    return all if term.blank?

    wildcard = "%#{term.to_s.strip.downcase}%"
    where(
      "LOWER(first_name) LIKE :term OR LOWER(last_name) LIKE :term OR LOWER(email) LIKE :term OR LOWER(phone) LIKE :term",
      term: wildcard
    )
  }

  def full_name
    [first_name, middle_name.presence, last_name].compact.join(" ")
  end
end
