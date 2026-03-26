class AddMenuFieldsToHomepageCards < ActiveRecord::Migration[5.2]
  def up
    add_column :homepage_cards, :description, :text
    add_column :homepage_cards, :index_path, :string
    add_column :homepage_cards, :new_path, :string
    add_column :homepage_cards, :index_label, :string
    add_column :homepage_cards, :create_label, :string
    add_column :homepage_cards, :resource_class_name, :string

    HomepageCard.reset_column_information

    HomepageCard.find_each do |card|
      card.update!(
        description: "Open the #{card.title.downcase} listing or create a new record from this dashboard.",
        index_path: "/#{card.resource_key}",
        new_path: "/#{card.resource_key}/new?return_to=%2F",
        index_label: "All #{card.title}",
        create_label: "Create #{card.resource_key.to_s.singularize.humanize}",
        resource_class_name: card.resource_key.to_s.classify
      )
    end
  end

  def down
    remove_column :homepage_cards, :resource_class_name, :string
    remove_column :homepage_cards, :create_label, :string
    remove_column :homepage_cards, :index_label, :string
    remove_column :homepage_cards, :new_path, :string
    remove_column :homepage_cards, :index_path, :string
    remove_column :homepage_cards, :description, :text
  end
end
