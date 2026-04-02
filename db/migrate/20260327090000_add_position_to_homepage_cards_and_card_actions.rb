class AddPositionToHomepageCardsAndCardActions < ActiveRecord::Migration[5.2]
  def change
    add_column :homepage_cards, :position, :integer
    add_column :card_actions, :position, :integer

    add_index :homepage_cards, :position
    add_index :card_actions, [:homepage_card_id, :position]
  end
end
