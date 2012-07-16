class AddGoalkeeperToGoal < ActiveRecord::Migration
  def change
    add_column :goals, :goalkeeper_id, :integer

    add_index :goals, :goalkeeper_id
  end
end
