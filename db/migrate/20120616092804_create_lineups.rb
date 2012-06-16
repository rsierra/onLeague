class CreateLineups < ActiveRecord::Migration
  def change
    create_table :lineups do |t|
      t.references :game
      t.references :player

      t.timestamps
    end
    add_index :lineups, :game_id
    add_index :lineups, :player_id
  end
end
