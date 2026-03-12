class AddProvinceToCities < ActiveRecord::Migration[5.2]
  def change
    add_reference :cities, :province, foreign_key: true
  end
end
