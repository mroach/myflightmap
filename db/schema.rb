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

ActiveRecord::Schema.define(version: 20141220011324) do

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

  create_table "audits", force: true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index"
  add_index "audits", ["created_at"], name: "index_audits_on_created_at"
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid"
  add_index "audits", ["user_id", "user_type"], name: "user_index"

  create_table "callback_logs", force: true do |t|
    t.string   "provider",    null: false
    t.string   "url"
    t.text     "data"
    t.string   "target_type"
    t.string   "target_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flights", force: true do |t|
    t.integer  "user_id"
    t.integer  "trip_id"
    t.string   "flight_code"
    t.string   "depart_airport",                       null: false
    t.date     "depart_date",                          null: false
    t.time     "depart_time"
    t.string   "arrive_airport",                       null: false
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
    t.boolean  "is_public",             default: true
    t.datetime "depart_time_utc"
    t.datetime "arrive_time_utc"
    t.string   "slug"
  end

  add_index "flights", ["airline_name"], name: "index_flights_on_airline_name"
  add_index "flights", ["arrive_airport"], name: "index_flights_on_arrive_airport"
  add_index "flights", ["arrive_time_utc"], name: "index_flights_on_arrive_date_utc_and_arrive_time_utc"
  add_index "flights", ["arrive_time_utc"], name: "index_flights_on_arrive_time_utc"
  add_index "flights", ["depart_airport"], name: "index_flights_on_depart_airport"
  add_index "flights", ["depart_time_utc"], name: "index_flights_on_depart_time_utc"
  add_index "flights", ["trip_id"], name: "index_flights_on_trip_id"
  add_index "flights", ["user_id", "slug"], name: "index_flights_on_user_id_and_slug", unique: true
  add_index "flights", ["user_id"], name: "index_flights_on_user_id"

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "identities", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id"

  create_table "trips", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "purpose"
    t.integer  "flight_count"
    t.date     "begin_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",    default: true
    t.string   "slug"
  end

  add_index "trips", ["user_id", "slug"], name: "index_trips_on_user_id_and_slug", unique: true
  add_index "trips", ["user_id"], name: "index_trips_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "image"
    t.string   "username"
    t.boolean  "admin",                  default: false
    t.string   "id_hash"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["id_hash"], name: "index_users_on_id_hash"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username"

end
