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

ActiveRecord::Schema[8.1].define(version: 2026_10_02_195440) do
  create_table "admins", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "camp_assignments", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "camp_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camp_id"], name: "index_camp_assignments_on_camp_id"
    t.index ["team_id", "camp_id"], name: "index_camp_assignments_on_team_id_and_camp_id", unique: true
    t.index ["team_id"], name: "index_camp_assignments_on_team_id"
  end

  create_table "camps", force: :cascade do |t|
    t.string "name", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_camps_on_name", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.integer "camp_id", null: false
    t.integer "team_id", null: false
    t.string "opponent_name", null: false
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
    t.integer "team_id"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "camp_assignments", "camps"
  add_foreign_key "camp_assignments", "teams"
  add_foreign_key "games", "camps"
  add_foreign_key "games", "teams"
  add_foreign_key "players", "teams"
end
