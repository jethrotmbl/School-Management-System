class CreateCities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.string :name
      t.text :description
      t.text :remarks
      t.boolean :is_municipality

      t.timestamps
    end
  end
end
