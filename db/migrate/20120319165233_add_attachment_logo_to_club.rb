class AddAttachmentLogoToClub < ActiveRecord::Migration
  def self.up
    change_table :clubs do |t|
      t.has_attached_file :logo
    end
  end

  def self.down
    drop_attached_file :clubs, :logo
  end
end
