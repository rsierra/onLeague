class RemoveDescriptionFromClub < ActiveRecord::Migration
  def change
    remove_column :clubs, :description
  end
end
