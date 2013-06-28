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

ActiveRecord::Schema.define(:version => 20130627024343) do

  create_table "alliance_invites", :force => true do |t|
    t.integer  "invited_by_id"
    t.integer  "redeemed_by_id"
    t.integer  "alliance_id"
    t.string   "token"
    t.boolean  "used"
    t.string   "email"
    t.datetime "invited_on"
    t.datetime "redeemed_on"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "alliance_invites", ["id"], :name => "id_index"
  add_index "alliance_invites", ["invited_by_id"], :name => "profile_id_index"

  create_table "alliance_members", :force => true do |t|
    t.datetime "join_date"
    t.datetime "leave_date"
    t.integer  "start_credit"
    t.integer  "leave_credit"
    t.integer  "alliance_id"
    t.integer  "profile_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "alliance_members", ["alliance_id"], :name => "alliance_id_index"
  add_index "alliance_members", ["id"], :name => "id_index"
  add_index "alliance_members", ["profile_id"], :name => "profile_id_index"

  create_table "alliances", :force => true do |t|
    t.string   "name"
    t.integer  "ranking"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "credit"
    t.integer  "RAC"
    t.string   "tags"
    t.text     "desc"
    t.string   "country"
    t.integer  "old_id"
  end

  add_index "alliances", ["credit"], :name => "credit_desc"
  add_index "alliances", ["id"], :name => "id_index"
  add_index "alliances", ["ranking"], :name => "ranking_asc"

  create_table "boinc_stats_items", :force => true do |t|
    t.integer  "boinc_id"
    t.integer  "credit"
    t.integer  "RAC"
    t.integer  "rank"
    t.integer  "general_stats_item_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "boinc_stats_items", ["general_stats_item_id"], :name => "general_stats_item_index"
  add_index "boinc_stats_items", ["id"], :name => "id_index"

  create_table "bonus_credits", :force => true do |t|
    t.integer  "amount"
    t.text     "reason"
    t.integer  "general_stats_item_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "bonus_credits", ["general_stats_item_id"], :name => "general_stats_item_index"
  add_index "bonus_credits", ["id"], :name => "id_index"

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "daily_alliance_credit", :force => true do |t|
    t.integer "alliance_id"
    t.integer "old_alliance_id"
    t.integer "day"
    t.integer "current_members"
    t.integer "daily_credit"
    t.integer "total_credit"
    t.integer "rank"
  end

  create_table "general_stats_items", :force => true do |t|
    t.integer  "total_credit"
    t.integer  "recent_avg_credit"
    t.integer  "rank"
    t.integer  "profile_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "last_trophy_credit_value", :default => 0,     :null => false
    t.boolean  "power_user",               :default => false, :null => false
  end

  add_index "general_stats_items", ["id"], :name => "id_index"
  add_index "general_stats_items", ["profile_id"], :name => "profile_id_index"
  add_index "general_stats_items", ["rank"], :name => "rank_asc"
  add_index "general_stats_items", ["total_credit"], :name => "total_credit_index_desc"

  create_table "nereus_stats_items", :force => true do |t|
    t.integer  "nereus_id"
    t.integer  "credit",                             :default => 0
    t.integer  "daily_credit",                       :default => 0
    t.integer  "rank",                               :default => 0
    t.integer  "general_stats_item_id"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "network_limit",         :limit => 8, :default => 0
    t.integer  "monthly_network_usage", :limit => 8, :default => 0
    t.integer  "paused",                             :default => 0
    t.integer  "active"
    t.integer  "online_today"
    t.integer  "online_now"
    t.integer  "mips_now"
    t.integer  "mips_today"
    t.datetime "last_checked_time"
  end

  add_index "nereus_stats_items", ["general_stats_item_id"], :name => "general_stats_item_index"
  add_index "nereus_stats_items", ["id"], :name => "id_index"

  create_table "news", :force => true do |t|
    t.string   "title"
    t.text     "short"
    t.text     "long"
    t.boolean  "published"
    t.datetime "published_time"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "news", ["id"], :name => "id_index"
  add_index "news", ["published_time"], :name => "pubished_time_index_asc"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "slug"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "parent_id"
  end

  add_index "pages", ["id"], :name => "id_index"

  create_table "profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "second_name"
    t.string   "country"
    t.integer  "user_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "alliance_id"
    t.integer  "alliance_leader_id"
    t.datetime "alliance_join_date"
    t.integer  "new_profile_step",   :default => 0,    :null => false
    t.string   "nickname"
    t.boolean  "use_full_name",      :default => true
    t.datetime "announcement_time"
  end

  add_index "profiles", ["alliance_leader_id"], :name => "alliance_leader_id_index"
  add_index "profiles", ["id"], :name => "id_index"
  add_index "profiles", ["user_id"], :name => "user_id_index"

  create_table "profiles_trophies", :force => true do |t|
    t.integer  "trophy_id"
    t.integer  "profile_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "profiles_trophies", ["id"], :name => "id_index"
  add_index "profiles_trophies", ["profile_id", "trophy_id"], :name => "index_profiles_trophies_on_profile_id_and_trophy_id"
  add_index "profiles_trophies", ["profile_id"], :name => "profile_id_index"
  add_index "profiles_trophies", ["trophy_id", "profile_id"], :name => "index_profiles_trophies_on_trophy_id_and_profile_id"
  add_index "profiles_trophies", ["trophy_id"], :name => "trophy_id_index"

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

  create_table "site_stats", :force => true do |t|
    t.string   "name"
    t.string   "current_value"
    t.string   "previous_value"
    t.datetime "change_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "trophies", :force => true do |t|
    t.string   "title"
    t.text     "desc"
    t.integer  "credits"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "hidden"
  end

  add_index "trophies", ["id"], :name => "id_index"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",                   :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.boolean  "admin",                                :default => false, :null => false
    t.boolean  "mod",                                  :default => false, :null => false
    t.string   "username"
    t.string   "old_site_password_salt",               :default => "",    :null => false
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["id"], :name => "id_index"
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token", :unique => true
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
