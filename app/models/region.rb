class Region < ApplicationRecord
    belongs_to :country, optional: true
    has_many :provinces, dependent: :destroy
end
