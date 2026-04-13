class StudentGuardian < ApplicationRecord
  belongs_to :student
  belongs_to :guardian

  validates :student_id, uniqueness: { scope: :guardian_id }
  validates :relationship_to_student, length: { maximum: 100 }, allow_blank: true
end
