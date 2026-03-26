class CreateCardActions < ActiveRecord::Migration[5.2]
  class MigrationHomepageCard < ApplicationRecord
    self.table_name = "homepage_cards"
  end

  class MigrationCardAction < ApplicationRecord
    self.table_name = "card_actions"
  end

  def up
    create_table :card_actions do |t|
      t.references :homepage_card, foreign_key: true
      t.string :label
      t.string :path
      t.string :button_class
      t.integer :position
      t.boolean :active

      t.timestamps
    end

    MigrationHomepageCard.reset_column_information
    MigrationCardAction.reset_column_information

    MigrationHomepageCard.find_each do |card|
      if card.respond_to?(:index_label) && card.index_label.present? && card.index_path.present?
        MigrationCardAction.create!(
          homepage_card_id: card.id,
          label: card.index_label,
          path: card.index_path,
          button_class: "btn btn-outline-brand resource-card__button",
          position: 1,
          active: true
        )
      end

      if card.respond_to?(:create_label) && card.create_label.present? && card.new_path.present?
        MigrationCardAction.create!(
          homepage_card_id: card.id,
          label: card.create_label,
          path: card.new_path,
          button_class: "btn btn-brand resource-card__button",
          position: 2,
          active: true
        )
      end
    end
  end

  def down
    drop_table :card_actions
  end
end
