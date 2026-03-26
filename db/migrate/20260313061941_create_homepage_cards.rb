class CreateHomepageCards < ActiveRecord::Migration[5.2]
  def change
    create_table :homepage_cards do |t|
      t.string :title
      t.string :resource_key
      t.string :icon
      t.integer :position
      t.boolean :active

      t.timestamps
    end
  end
end
