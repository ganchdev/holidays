# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_17_234825) do
  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authorized_users", force: :cascade do |t|
    t.string "email_address"
    t.integer "account_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_authorized_users_on_account_id"
    t.index ["user_id"], name: "index_authorized_users_on_user_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.integer "room_id", null: false
    t.integer "adults", default: 1
    t.integer "children", default: 0
    t.text "notes"
    t.decimal "deposit", precision: 10, scale: 2
    t.datetime "cancelled_at"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.index ["cancelled_at"], name: "index_bookings_on_cancelled_at"
    t.index ["ends_at"], name: "index_bookings_on_ends_at"
    t.index ["room_id"], name: "index_bookings_on_room_id"
    t.index ["starts_at"], name: "index_bookings_on_starts_at"
  end

  create_table "properties", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_properties_on_account_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "property_id", null: false
    t.integer "capacity"
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.index ["property_id"], name: "index_rooms_on_property_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "account_id"
    t.boolean "admin"
    t.string "name"
    t.string "first_name"
    t.string "last_name"
    t.string "image"
    t.string "email_address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
end
