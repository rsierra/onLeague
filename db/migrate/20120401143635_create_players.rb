class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name,         :limit => 64
      t.date :born,           :default => '1900-01-01'
      t.boolean :active,      :default => false
      t.references :country
      t.string :slug,         :unique => true
      t.timestamps
    end
    add_index :players, :country_id
    add_index :players, :slug, :unique => true
  end
end
