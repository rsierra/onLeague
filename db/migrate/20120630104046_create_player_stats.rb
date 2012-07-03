class CreatePlayerStats < ActiveRecord::Migration
  def change
    create_table :player_stats do |t|
      t.references :player
      t.references :game
      t.integer :points, limit: 1, default: 0
      t.integer :goals_scored, limit: 1, default: 0
      t.integer :assists, limit: 1, default: 0
      t.integer :goals_conceded, limit: 1, default: 0
      t.integer :yellow_cards, limit: 1, default: 0
      t.integer :red_cards, limit: 1, default: 0
      t.integer :lineups, limit: 1, default: 0
      t.integer :games_played, limit: 1, default: 0
      t.integer :minutes_played, limit: 1, default: 0

      t.timestamps
    end
    add_index :player_stats, :player_id
    add_index :player_stats, :game_id
  end
end
