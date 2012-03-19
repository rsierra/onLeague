class AddClubTranslation < ActiveRecord::Migration
  def up
    Club.create_translation_table! :description => :text
  end

  def down
    Club.drop_translation_table!
  end
end
