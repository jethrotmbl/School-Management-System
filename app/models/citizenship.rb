class Citizenship < ApplicationRecord
  has_many :students, dependent: :nullify
  has_many :guardians, dependent: :nullify
  has_many :teachers, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
