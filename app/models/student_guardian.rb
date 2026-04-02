class StudentGuardian < ApplicationRecord
  belongs_to :student
  belongs_to :guardian

  validates :student_id, uniqueness: { scope: :guardian_id }
end
