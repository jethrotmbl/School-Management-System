class HomeController < ApplicationController
  RESOURCE_DEFINITIONS = [
    { key: :countries, model: Country, icon: "globe2" },
    { key: :regions, model: Region, icon: "diagram-3-fill" },
    { key: :provinces, model: Province, icon: "signpost-2-fill" },
    { key: :cities, model: City, icon: "building" },
    { key: :barangays, model: Barangay, icon: "pin-map-fill" }
  ].freeze

  def index
    @resource_cards = resource_cards
  end

  private

  def resource_cards
    RESOURCE_DEFINITIONS.map do |resource|
      key = resource.fetch(:key)
      singular = key.to_s.singularize
      model = resource.fetch(:model)

      {
        title: key.to_s.humanize,
        icon: resource.fetch(:icon),
        count: model.count,
        index_path: helpers.public_send("#{key}_path"),
        new_path: helpers.public_send("new_#{singular}_path", return_to: helpers.root_path),
        index_label: "All #{key.to_s.humanize}",
        create_label: "Create #{singular.humanize}"
      }
    end
  end
end
