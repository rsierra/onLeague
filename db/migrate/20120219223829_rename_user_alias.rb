class RenameUserAlias < ActiveRecord::Migration
  def change
    rename_column :users, :alias, :name
  end
end
