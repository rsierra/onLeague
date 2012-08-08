class CreateGameMarks < ActiveRecord::Migration
  def change
    create_table :game_marks do |t|
      t.references :player
      t.references :game
      t.integer :mark, limit: 1, default: 0

      t.timestamps
    end
    add_index :game_marks, :player_id
    add_index :game_marks, :game_id
  end
end
