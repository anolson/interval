# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "category"
    t.string   "permalink"
    t.integer  "number_of_views", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "workout_id"
  end

  create_table "data_values", :force => true do |t|
    t.integer "training_file_id"
    t.integer "relative_time"
    t.integer "absolute_time"
    t.float   "power"
    t.integer "cadence"
    t.integer "heartrate"
    t.float   "speed"
    t.float   "distance"
    t.float   "torque",           :default => 0.0
    t.integer "time",             :default => 0
    t.integer "time_with_pauses", :default => 0
    t.integer "time_of_day",      :default => 0
  end

  add_index "data_values", ["training_file_id"], :name => "index_data_values_on_training_file_id"

  create_table "markers", :force => true do |t|
    t.boolean "active",                  :default => true
    t.integer "avg_cadence",             :default => 0
    t.integer "avg_heartrate",           :default => 0
    t.integer "avg_power",               :default => 0
    t.float   "avg_speed",               :default => 0.0
    t.string  "comment"
    t.integer "duration_seconds",        :default => 0
    t.float   "distance",                :default => 0.0
    t.integer "end"
    t.integer "energy",                  :default => 0
    t.integer "max_cadence",             :default => 0
    t.integer "max_heartrate",           :default => 0
    t.integer "max_power",               :default => 0
    t.float   "max_speed",               :default => 0.0
    t.integer "start"
    t.integer "workout_id"
    t.integer "normalized_power",        :default => 0
    t.float   "average_power_to_weight", :default => 0.0
    t.float   "maximum_power_to_weight", :default => 0.0
  end

  create_table "peak_powers", :force => true do |t|
    t.integer "duration",   :default => 0
    t.integer "start",      :default => 0
    t.float   "value",      :default => 0.0
    t.integer "workout_id", :default => 0
  end

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "workout_limit"
    t.string   "limit_by"
    t.integer  "storage_limit"
    t.float    "price"
    t.boolean  "enabled"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights", :force => true do |t|
    t.string  "controller"
    t.string  "action"
    t.integer "role_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "roles_users", :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "subscriptions", :force => true do |t|
    t.string   "paypal_profile_idcd"
    t.integer  "plan_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "training_files", :force => true do |t|
    t.datetime "created_at"
    t.string   "filename"
    t.binary   "payload"
    t.text     "powermeter_properties"
    t.integer  "workout_id"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.boolean  "disabled",         :default => false
    t.datetime "last_login"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "username"
    t.boolean  "terms_of_service"
    t.text     "preferences"
    t.text     "email"
  end

  create_table "workouts", :force => true do |t|
    t.datetime "created_at"
    t.string   "name"
    t.text     "notes"
    t.datetime "performed_on"
    t.string   "permalink"
    t.boolean  "uploaded",     :default => false
    t.integer  "user_id"
    t.string   "state",        :default => "created"
  end

end
