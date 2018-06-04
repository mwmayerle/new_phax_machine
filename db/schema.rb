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

ActiveRecord::Schema.define(version: 2018_06_03_195758) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fax_numbers", force: :cascade do |t|
    t.string "fax_number", null: false
    t.string "fax_number_label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.bigint "group_leader_id"
    t.string "group_name"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_leader_id"], name: "index_groups_on_group_leader_id"
  end

  create_table "super_users", force: :cascade do |t|
    t.string "super_user_email", null: false
    t.string "fax_tag"
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "group_leader_id"
    t.boolean "is_admin", default: false
    t.boolean "is_group_leader", default: false
    t.string "email", null: false
    t.string "fax_tag"
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_leader_id"], name: "index_users_on_group_leader_id"
  end

end
