class AddEuToPlayers < ActiveRecord::Migration
  def up
    add_column :players, :eu, :boolean, :default => true
    remove_column :countries, :eu
  end

  def down
    add_column :countries, :eu, :boolean, :default => true
    remove_column :players, :eu
  end
end
