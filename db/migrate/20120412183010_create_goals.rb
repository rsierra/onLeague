class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.references :game
      t.references :scorer
      t.references :assistant
      t.integer :minute
      t.string :kind

      t.timestamps
    end
    add_index :goals, :game_id
    add_index :goals, :scorer_id
    add_index :goals, :assistant_id
  end
end
