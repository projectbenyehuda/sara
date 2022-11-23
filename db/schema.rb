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

ActiveRecord::Schema[7.0].define(version: 2022_11_20_164633) do
  create_table "ignored_items", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "external_id", null: false
    t.integer "source", null: false
    t.timestamp "created_at"
    t.index ["project_id", "external_id", "source"], name: "index_ignored_items_on_project_id_and_external_id_and_source", unique: true
    t.index ["project_id"], name: "index_ignored_items_on_project_id"
  end

  create_table "projects", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "queries", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id", null: false
    t.index ["project_id"], name: "index_queries_on_project_id"
  end

  create_table "response_items", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "query_id"
    t.integer "source", null: false
    t.integer "media_type", null: false
    t.string "url", limit: 2048, null: false
    t.string "media_url", limit: 2048
    t.string "thumbnail_url", limit: 2048
    t.string "title"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id", null: false
    t.integer "index", null: false
    t.string "item_date"
    t.integer "normalized_year"
    t.boolean "favorite", default: false, null: false
    t.bigint "project_id", null: false
    t.index ["project_id"], name: "index_response_items_on_project_id"
    t.index ["query_id"], name: "index_response_items_on_query_id"
  end

  add_foreign_key "ignored_items", "projects"
  add_foreign_key "queries", "projects"
  add_foreign_key "response_items", "projects"
  add_foreign_key "response_items", "queries"
end
