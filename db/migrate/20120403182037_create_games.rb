class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :league
      t.datetime :date
      t.integer :week,        limit: 2
      t.integer :season,      limit: 4
      t.references :club_home
      t.references :club_away
      t.string :status,       limit: 24
      t.string :slug

      t.timestamps
    end
    add_index :games, :league_id
    add_index :games, :club_home_id
    add_index :games, :club_away_id
    add_index :games, :slug, unique: true
  end
end
