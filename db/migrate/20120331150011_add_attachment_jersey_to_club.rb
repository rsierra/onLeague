class AddAttachmentJerseyToClub < ActiveRecord::Migration
  def self.up
    change_table :clubs do |t|
      t.has_attached_file :jersey
      t.string :number_color, :default => '#000000'
    end
  end

  def self.down
    drop_attached_file :clubs, :jersey
    remove_column :clubs, :number_color
  end
end
