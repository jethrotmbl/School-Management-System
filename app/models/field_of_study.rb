class FieldOfStudy < ApplicationRecord
  belongs_to :degree, optional: true
  has_many :academic_classes, dependent: :nullify

  validates :name, presence: true
  validates :name, uniqueness: { scope: :degree_id }
  validates :code, uniqueness: true, allow_blank: true
end
