class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :game
      t.references :player
      t.integer :minute, limit: 3
      t.string :kind

      t.timestamps
    end
    add_index :cards, :game_id
    add_index :cards, :player_id
  end
end
