class CreateOauthProviders < ActiveRecord::Migration
  def change
    create_table :oauth_providers do |t|
      t.string :provider
      t.string :uid
      t.string :uname
      t.string :uemail
      t.references :user

      t.timestamps
    end
    add_index :oauth_providers, :user_id
    add_index :oauth_providers, :uid
  end
end
