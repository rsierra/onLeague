# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120331171421) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "club_translations", :force => true do |t|
    t.integer  "club_id"
    t.string   "locale"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "club_translations", ["club_id"], :name => "index_club_translations_on_club_id"
  add_index "club_translations", ["locale"], :name => "index_club_translations_on_locale"

  create_table "clubs", :force => true do |t|
    t.string   "name",                :limit => 25
    t.string   "short_name",          :limit => 3
    t.string   "slug"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "jersey_file_name"
    t.string   "jersey_content_type"
    t.integer  "jersey_file_size"
    t.datetime "jersey_updated_at"
    t.string   "number_color",                      :default => "#000000"
  end

  add_index "clubs", ["slug"], :name => "index_clubs_on_slug", :unique => true

  create_table "clubs_leagues", :id => false, :force => true do |t|
    t.integer "club_id"
    t.integer "league_id"
  end

  add_index "clubs_leagues", ["club_id", "league_id"], :name => "index_clubs_leagues_on_club_id_and_league_id"
  add_index "clubs_leagues", ["league_id", "club_id"], :name => "index_clubs_leagues_on_league_id_and_club_id"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.boolean  "eu",                :default => false
    t.string   "flag_file_name"
    t.string   "flag_content_type"
    t.integer  "flag_file_size"
    t.datetime "flag_updated_at"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "country_translations", :force => true do |t|
    t.integer  "country_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "country_translations", ["country_id"], :name => "index_country_translations_on_country_id"
  add_index "country_translations", ["locale"], :name => "index_country_translations_on_locale"

  create_table "leagues", :force => true do |t|
    t.string   "name"
    t.integer  "week",       :limit => 2
    t.integer  "season"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "active",                  :default => false
  end

  create_table "oauth_providers", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "uname"
    t.string   "uemail"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "oauth_providers", ["uid"], :name => "index_oauth_providers_on_uid"
  add_index "oauth_providers", ["user_id"], :name => "index_oauth_providers_on_user_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 5
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
