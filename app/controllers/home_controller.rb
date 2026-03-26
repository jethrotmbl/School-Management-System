class HomeController < ApplicationController
  def index
    @resource_cards = HomepageCard.includes(:card_actions).order(:id)
    @counts = {
      "Countries" => Country.count,
      "Regions" => Region.count,
      "Provinces" => Province.count,
      "Cities" => City.count,
      "Barangays" => Barangay.count
    }
  end
end
