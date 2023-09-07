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

ActiveRecord::Schema[7.0].define(version: 2023_09_07_213559) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "twitch_games", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
  end

  create_table "twitch_users", force: :cascade do |t|
    t.string "login"
    t.integer "follower_count", default: 0
    t.boolean "is_partner", default: false
    t.boolean "is_affiliate", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "twitch_videos", force: :cascade do |t|
    t.bigint "stream_id"
    t.string "language"
    t.string "title"
    t.integer "view_count"
    t.string "video_type"
    t.bigint "twitch_user_id"
    t.string "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "twitch_game_id"
  end

  add_foreign_key "twitch_games", "categories"
  add_foreign_key "twitch_videos", "twitch_games"
  add_foreign_key "twitch_videos", "twitch_users"
end
