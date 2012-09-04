class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.references :user
      t.references :league
      t.integer :season
      t.string :name, limit: 25
      t.float :money
      t.boolean :active,  default: false
      t.integer :activation_week, limit: 1

      t.timestamps
    end
    add_index :teams, :user_id
    add_index :teams, :league_id
  end
end
