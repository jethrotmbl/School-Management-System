class AddCityToBarangays < ActiveRecord::Migration[5.2]
  def change
    add_reference :barangays, :city, foreign_key: true
  end
end
