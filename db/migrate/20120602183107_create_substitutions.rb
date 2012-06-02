class CreateSubstitutions < ActiveRecord::Migration
  def change
    create_table :substitutions do |t|
      t.references :game
      t.references :player_out
      t.references :player_in
      t.integer :minute, :limit => 3

      t.timestamps
    end
    add_index :substitutions, :game_id
    add_index :substitutions, :player_out_id
    add_index :substitutions, :player_in_id
  end
end
