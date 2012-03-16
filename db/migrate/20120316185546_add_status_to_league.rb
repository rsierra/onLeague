class AddStatusToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :active, :boolean, :default => false
  end
end
