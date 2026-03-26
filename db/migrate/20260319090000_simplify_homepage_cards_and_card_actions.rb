class SimplifyHomepageCardsAndCardActions < ActiveRecord::Migration[5.2]
  def change
    remove_column :homepage_cards, :resource_key, :string
    remove_column :homepage_cards, :position, :integer
    remove_column :homepage_cards, :active, :boolean
    remove_column :homepage_cards, :resource_class_name, :string

    remove_column :card_actions, :button_class, :string
    remove_column :card_actions, :position, :integer
    remove_column :card_actions, :active, :boolean
  end
end
