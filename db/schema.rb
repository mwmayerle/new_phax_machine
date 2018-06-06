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

ActiveRecord::Schema.define(version: 2018_06_05_211211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.integer "client_manager_id", null: false
    t.string "client_label", null: false
    t.string "fax_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fax_numbers", force: :cascade do |t|
    t.string "fax_number_label"
    t.string "fax_number", null: false
    t.string "faxable_type", null: false
    t.integer "faxable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "group_label"
    t.string "display_label"
    t.string "fax_tag"
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer "client_id"
    t.string "type", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "fax_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
