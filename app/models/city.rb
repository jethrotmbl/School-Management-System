class City < ApplicationRecord
    belongs_to :province, optional: true
    has_many :barangays, dependent: :destroy
end
