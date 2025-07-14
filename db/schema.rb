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

ActiveRecord::Schema[8.0].define(version: 2025_07_13_203032) do
  create_table "albums", force: :cascade do |t|
    t.string "title"
    t.date "release_date"
    t.integer "primary_artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["primary_artist_id"], name: "index_albums_on_primary_artist_id"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "iso_code"
    t.string "name"
    t.string "geopoint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_rankings", force: :cascade do |t|
    t.integer "track_id", null: false
    t.integer "country_id", null: false
    t.date "snapshot_date"
    t.integer "daily_rank"
    t.integer "popularity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_daily_rankings_on_country_id"
    t.index ["track_id"], name: "index_daily_rankings_on_track_id"
  end

  create_table "track_artists", force: :cascade do |t|
    t.integer "track_id", null: false
    t.integer "artist_id", null: false
    t.boolean "is_primary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_track_artists_on_artist_id"
    t.index ["track_id"], name: "index_track_artists_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "name"
    t.string "spotify_id"
    t.integer "duration_ms"
    t.decimal "danceability"
    t.decimal "energy"
    t.integer "key"
    t.integer "mode"
    t.decimal "tempo"
    t.integer "time_signature"
    t.integer "album_id", null: false
    t.integer "primary_artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_tracks_on_album_id"
    t.index ["primary_artist_id"], name: "index_tracks_on_primary_artist_id"
  end

  add_foreign_key "albums", "artists", column: "primary_artist_id"
  add_foreign_key "daily_rankings", "countries"
  add_foreign_key "daily_rankings", "tracks"
  add_foreign_key "track_artists", "artists"
  add_foreign_key "track_artists", "tracks"
  add_foreign_key "tracks", "albums"
  add_foreign_key "tracks", "artists", column: "primary_artist_id"
end
