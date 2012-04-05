class AddDateToClubFile < ActiveRecord::Migration
  def change
    add_column :club_files, :date_in, :date
    add_column :club_files, :date_out, :date
    remove_column :club_files, :week_in
    remove_column :club_files, :season_in
    remove_column :club_files, :week_out
    remove_column :club_files, :season_out
  end
end
