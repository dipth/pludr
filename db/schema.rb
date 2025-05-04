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

ActiveRecord::Schema[8.0].define(version: 2025_05_04_135402) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "game_words", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "word_id", null: false
    t.citext "value"
    t.string "hashed_value"
    t.integer "length"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "value"], name: "index_game_words_on_game_id_and_value", unique: true
    t.index ["game_id"], name: "index_game_words_on_game_id"
    t.index ["hashed_value"], name: "index_game_words_on_hashed_value"
    t.index ["length"], name: "index_game_words_on_length"
    t.index ["score"], name: "index_game_words_on_score"
    t.index ["value"], name: "index_game_words_on_value"
    t.index ["word_id"], name: "index_game_words_on_word_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "workflow_state", null: false
    t.string "letters", null: false
    t.string "salt", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.jsonb "letter_scores", default: {}
    t.integer "min_words", null: false
    t.integer "max_words", null: false
    t.integer "game_words_count", default: 0
    t.index ["workflow_state"], name: "index_games_on_workflow_state"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.citext "username", null: false
    t.string "name", null: false
    t.citext "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "words", force: :cascade do |t|
    t.citext "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "letter_pairs", default: [], array: true
    t.index ["deleted_at"], name: "index_words_on_deleted_at"
    t.index ["letter_pairs"], name: "index_words_on_letter_pairs", using: :gin
    t.index ["value"], name: "index_words_on_value", unique: true
  end

  add_foreign_key "game_words", "games", on_delete: :cascade
  add_foreign_key "game_words", "words", on_delete: :nullify
  add_foreign_key "sessions", "users"
end
