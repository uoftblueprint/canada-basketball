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

ActiveRecord::Schema[8.1].define(version: 2026_11_07_011634) do
  create_table "admins", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "camp_registrations", force: :cascade do |t|
    t.integer "camp_id", null: false
    t.integer "player_id", null: false
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camp_id", "player_id"], name: "index_camp_registrations_on_camp_id_and_player_id", unique: true
    t.index ["camp_id"], name: "index_camp_registrations_on_camp_id"
    t.index ["player_id"], name: "index_camp_registrations_on_player_id"
    t.index ["team_id"], name: "index_camp_registrations_on_team_id"
  end

  create_table "camps", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.string "password_digest"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_camps_on_name", unique: true
  end

  create_table "game_events", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "player_id"
    t.boolean "is_opponent", default: false, null: false
    t.string "kind", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "created_at", "id"], name: "index_game_events_on_game_id_and_created_at_and_id"
    t.index ["game_id", "is_opponent", "player_id"], name: "index_game_events_on_game_id_and_is_opponent_and_player_id"
    t.index ["game_id"], name: "index_game_events_on_game_id"
    t.index ["player_id"], name: "index_game_events_on_player_id"
    t.check_constraint "NOT (is_opponent AND player_id IS NOT NULL)", name: "opponent_events_have_no_player"
  end

  create_table "game_stat_lines", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "player_id"
    t.boolean "is_opponent", default: false, null: false
    t.integer "two_pm", default: 0, null: false
    t.integer "two_pa", default: 0, null: false
    t.integer "three_pm", default: 0, null: false
    t.integer "three_pa", default: 0, null: false
    t.integer "ftm", default: 0, null: false
    t.integer "fta", default: 0, null: false
    t.integer "fgm", default: 0, null: false
    t.integer "fga", default: 0, null: false
    t.integer "pts", default: 0, null: false
    t.integer "orb", default: 0, null: false
    t.integer "drb", default: 0, null: false
    t.integer "trb", default: 0, null: false
    t.integer "ast", default: 0, null: false
    t.integer "tov", default: 0, null: false
    t.integer "pf", default: 0, null: false
    t.integer "stl", default: 0, null: false
    t.integer "blk", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "is_opponent"], name: "index_game_stat_lines_on_game_id_and_is_opponent", unique: true, where: "player_id IS NULL"
    t.index ["game_id", "player_id"], name: "index_game_stat_lines_on_game_id_and_player_id", unique: true, where: "player_id IS NOT NULL"
    t.index ["game_id"], name: "index_game_stat_lines_on_game_id"
    t.index ["player_id"], name: "index_game_stat_lines_on_player_id"
    t.check_constraint "NOT (is_opponent AND player_id IS NOT NULL)", name: "opponent_stat_lines_have_no_player"
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.integer "camp_id", null: false
    t.integer "team_id", null: false
    t.string "opponent_name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camp_id", "name"], name: "index_games_on_camp_id_and_name", unique: true
    t.index ["camp_id"], name: "index_games_on_camp_id"
    t.index ["team_id"], name: "index_games_on_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.integer "camp_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camp_id", "name"], name: "index_teams_on_camp_id_and_name", unique: true
    t.index ["camp_id"], name: "index_teams_on_camp_id"
  end

  add_foreign_key "camp_registrations", "camps"
  add_foreign_key "camp_registrations", "players"
  add_foreign_key "camp_registrations", "teams"
  add_foreign_key "game_events", "games"
  add_foreign_key "game_events", "players"
  add_foreign_key "game_stat_lines", "games"
  add_foreign_key "game_stat_lines", "players"
  add_foreign_key "games", "camps"
  add_foreign_key "games", "teams"
  add_foreign_key "teams", "camps"
end
