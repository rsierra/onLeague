class CreateClubFiles < ActiveRecord::Migration
  def change
    create_table :club_files do |t|
      t.references :club
      t.references :player
      t.integer :number
      t.string :position
      t.float :value
      t.integer :week_in
      t.integer :season_in
      t.integer :week_out
      t.integer :season_out

      t.timestamps
    end
    add_index :club_files, :club_id
    add_index :club_files, :player_id
  end
end
