class HomeController < ApplicationController
  def index
    dashboard = HomeDashboard.new
    dashboard.load
    @resource_cards = dashboard.resource_cards
    @summary_items = dashboard.summary_items
  end
end
