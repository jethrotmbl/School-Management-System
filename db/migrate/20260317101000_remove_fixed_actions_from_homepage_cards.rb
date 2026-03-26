class RemoveFixedActionsFromHomepageCards < ActiveRecord::Migration[5.2]
  def change
    remove_column :homepage_cards, :index_path, :string
    remove_column :homepage_cards, :new_path, :string
    remove_column :homepage_cards, :index_label, :string
    remove_column :homepage_cards, :create_label, :string
  end
end
