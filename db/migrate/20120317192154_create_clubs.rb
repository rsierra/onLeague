class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |t|
      t.string :name,       :unique => true, :limit => 25
      t.string :short_name, :limit => 3
      t.string :slug,       :unique => true
      t.text :description

      t.timestamps
    end
    add_index :clubs, :slug, :unique => true
  end
end
