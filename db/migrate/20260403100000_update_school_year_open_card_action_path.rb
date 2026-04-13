class UpdateSchoolYearOpenCardActionPath < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
      UPDATE card_actions
      INNER JOIN homepage_cards ON homepage_cards.id = card_actions.homepage_card_id
      SET card_actions.path = '/school_years'
      WHERE card_actions.label = 'Open School Year'
        AND homepage_cards.title = 'School Years'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE card_actions
      INNER JOIN homepage_cards ON homepage_cards.id = card_actions.homepage_card_id
      SET card_actions.path = '/school_years/new?open_now=1'
      WHERE card_actions.label = 'Open School Year'
        AND homepage_cards.title = 'School Years'
    SQL
  end
end
