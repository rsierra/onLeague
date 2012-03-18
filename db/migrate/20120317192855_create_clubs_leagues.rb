class CreateClubsLeagues < ActiveRecord::Migration
  def change
    create_table :clubs_leagues, :id => false do |t|
        t.references :club
        t.references :league
    end
    add_index :clubs_leagues, [:club_id, :league_id]
    add_index :clubs_leagues, [:league_id, :club_id]
  end
end
