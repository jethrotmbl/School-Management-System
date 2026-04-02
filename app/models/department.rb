class Department < ApplicationRecord
  has_many :teachers, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :code, uniqueness: true, allow_blank: true
end
