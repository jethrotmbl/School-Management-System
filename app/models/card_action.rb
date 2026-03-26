class CardAction < ApplicationRecord
  belongs_to :homepage_card

  validates :label, :path, presence: true
end
