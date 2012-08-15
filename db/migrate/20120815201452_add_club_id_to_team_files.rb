class AddClubIdToTeamFiles < ActiveRecord::Migration
  def change
    add_column :team_files, :club_id, :integer
    add_index :team_files, :club_id
  end
end
