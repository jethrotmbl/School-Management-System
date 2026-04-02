class Degree < ApplicationRecord
  has_many :field_of_studies, dependent: :destroy
  has_many :academic_classes, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :code, uniqueness: true, allow_blank: true
end
