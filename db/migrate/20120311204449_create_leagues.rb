class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string :name
      t.integer :week,    :limit => 2
      t.integer :season,  :limit => 4

      t.timestamps
    end
  end
end
