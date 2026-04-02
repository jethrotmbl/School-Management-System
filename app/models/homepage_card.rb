class HomepageCard < ApplicationRecord
  has_many :card_actions, -> { order(:position) }, dependent: :destroy

  validates :title, :icon, :description, presence: true
  validates :title, uniqueness: true
end
