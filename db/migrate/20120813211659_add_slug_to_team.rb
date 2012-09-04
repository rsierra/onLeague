class AddSlugToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :slug, :string, :unique => true
    add_index :teams, :slug, :unique => true
  end
end
