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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140626144550) do

  create_table "airlines", force: true do |t|
    t.string   "iata_code"
    t.string   "icao_code"
    t.string   "name"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "alliance"
  end

  add_index "airlines", ["iata_code"], name: "index_airlines_on_iata_code", unique: true

  create_table "airports", force: true do |t|
    t.string   "iata_code"
    t.string   "icao_code"
    t.string   "name"
    t.string   "city"
    t.string   "country"
    t.decimal  "latitude",    precision: 10, scale: 6
    t.decimal  "longitude",   precision: 10, scale: 6
    t.string   "timezone"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "airports", ["iata_code"], name: "index_airports_on_iata_code", unique: true

  create_table "flights", force: true do |t|
    t.integer  "user_id"
    t.integer  "trip_id"
    t.string   "flight_code"
    t.string   "depart_airport",        null: false
    t.date     "depart_date",           null: false
    t.time     "depart_time"
    t.string   "arrive_airport",        null: false
    t.date     "arrive_date"
    t.time     "arrive_time"
    t.integer  "distance"
    t.integer  "duration"
    t.integer  "airline_id"
    t.string   "airline_name"
    t.string   "aircraft_name"
    t.string   "seat"
    t.string   "seat_class"
    t.string   "seat_location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "aircraft_type"
    t.string   "aircraft_registration"
    t.string   "flight_role"
    t.string   "purpose"
  end

  add_index "flights", ["airline_name"], name: "index_flights_on_airline_name"
  add_index "flights", ["arrive_airport"], name: "index_flights_on_arrive_airport"
  add_index "flights", ["depart_airport"], name: "index_flights_on_depart_airport"
  add_index "flights", ["trip_id"], name: "index_flights_on_trip_id"
  add_index "flights", ["user_id"], name: "index_flights_on_user_id"

  create_table "trips", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "purpose"
    t.integer  "flight_count"
    t.date     "begin_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trips", ["user_id"], name: "index_trips_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "image"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
