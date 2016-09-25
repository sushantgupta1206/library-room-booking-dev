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

ActiveRecord::Schema.define(version: 20160919133130) do

  create_table "bookings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.date     "day"
    t.integer  "start_time"
    t.integer  "end_time"
    t.string   "attendees"
    t.integer  "room_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_bookings_on_room_id", using: :btree
    t.index ["user_id"], name: "index_bookings_on_user_id", using: :btree
  end

  create_table "buildings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.integer  "building_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "room_type_id"
    t.index ["building_id"], name: "index_rooms_on_building_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "emailId"
    t.string   "password_digest"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "is_admin"
    t.boolean  "is_preconfigured"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_foreign_key "bookings", "rooms"
  add_foreign_key "bookings", "users"
  add_foreign_key "rooms", "buildings"
end
