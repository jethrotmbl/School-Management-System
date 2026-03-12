class Barangay < ApplicationRecord
  belongs_to :city, optional: true
end
