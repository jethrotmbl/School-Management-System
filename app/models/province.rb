class Province < ApplicationRecord
    belongs_to :region, optional: true
    has_many :cities, dependent: :destroy
end
