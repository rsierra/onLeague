class CreateTeamFiles < ActiveRecord::Migration
  def change
    create_table :team_files do |t|
      t.references :team
      t.references :player
      t.string :position
      t.float :value
      t.date :date_in
      t.date :date_out

      t.timestamps
    end
    add_index :team_files, :team_id
    add_index :team_files, :player_id
  end
end
