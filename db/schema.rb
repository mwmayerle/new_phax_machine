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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_06_19_182316) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.integer "client_manager_id"
    t.string "client_label", null: false
    t.string "fax_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fax_number_user_emails", force: :cascade do |t|
    t.integer "fax_number_id", null: false
    t.integer "user_email_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fax_numbers", force: :cascade do |t|
    t.integer "client_id"
    t.string "fax_number_label", default: "Unallocated"
    t.string "fax_number_display_label", default: "Unlabeled"
    t.string "fax_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_emails", force: :cascade do |t|
    t.integer "client_id"
    t.integer "user_id"
    t.string "caller_id_number"
    t.string "email_address", null: false
    t.string "fax_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer "client_id"
    t.string "email", default: "", null: false
    t.string "type", null: false
    t.string "situational"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
