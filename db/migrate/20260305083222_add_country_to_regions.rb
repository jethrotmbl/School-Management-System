class AddCountryToRegions < ActiveRecord::Migration[5.2]
  def change
    add_reference :regions, :country, foreign_key: true
  end
end
