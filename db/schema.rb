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

ActiveRecord::Schema[7.0].define(version: 2022_10_25_150712) do
  create_table "projects", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "queries", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id", null: false
    t.index ["project_id"], name: "index_queries_on_project_id"
  end

  create_table "response_items", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "query_id"
    t.integer "source", null: false
    t.integer "media_type", null: false
    t.string "url", null: false
    t.string "media_url"
    t.string "thumbnail_url"
    t.string "title"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.integer "index", null: false
    t.index ["query_id"], name: "index_response_items_on_query_id"
  end

  add_foreign_key "queries", "projects"
  add_foreign_key "response_items", "queries"
end
