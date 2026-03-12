class HomeController < ApplicationController
  def index
    @resource_cards = resource_cards
  end

  private

  def resource_cards
    %i[countries regions provinces cities barangays].map do |resource|
      singular = resource.to_s.singularize

      {
        title: resource.to_s.humanize,
        index_path: helpers.public_send("#{resource}_path"),
        new_path: helpers.public_send("new_#{singular}_path"),
        index_label: "All #{resource.to_s.humanize}",
        create_label: "Create #{singular.humanize}"
      }
    end
  end
end
