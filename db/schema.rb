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

ActiveRecord::Schema[8.1].define(version: 2026_10_15_170000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.integer "incident_id", null: false
    t.integer "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_comments_on_incident_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "user_one_id", null: false
    t.integer "user_two_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_one_id", "user_two_id"], name: "index_conversations_on_user_one_id_and_user_two_id", unique: true
    t.index ["user_one_id"], name: "index_conversations_on_user_one_id"
    t.index ["user_two_id"], name: "index_conversations_on_user_two_id"
  end

  create_table "incidents", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.string "location"
    t.datetime "occurred_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_incidents_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "official_record_reviews", force: :cascade do |t|
    t.integer "official_record_id", null: false
    t.integer "user_id", null: false
    t.integer "professionalism_rating", null: false
    t.integer "experience_rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["official_record_id", "user_id"], name: "index_official_record_reviews_on_record_and_user", unique: true
    t.index ["official_record_id"], name: "index_official_record_reviews_on_official_record_id"
    t.index ["user_id"], name: "index_official_record_reviews_on_user_id"
  end

  create_table "official_records", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "category", null: false
    t.string "name", null: false
    t.string "district"
    t.string "badge_number"
    t.string "precinct"
    t.string "state", null: false
    t.string "city", null: false
    t.text "incident_names"
    t.string "case_number"
    t.text "history"
    t.text "decisions"
    t.string "source_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_number"], name: "index_official_records_on_badge_number"
    t.index ["case_number"], name: "index_official_records_on_case_number"
    t.index ["category"], name: "index_official_records_on_category"
    t.index ["city"], name: "index_official_records_on_city"
    t.index ["district"], name: "index_official_records_on_district"
    t.index ["precinct"], name: "index_official_records_on_precinct"
    t.index ["state"], name: "index_official_records_on_state"
    t.index ["user_id"], name: "index_official_records_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "home"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "display_name", null: false
    t.text "bio"
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "incidents"
  add_foreign_key "comments", "users"
  add_foreign_key "conversations", "users", column: "user_one_id"
  add_foreign_key "conversations", "users", column: "user_two_id"
  add_foreign_key "incidents", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "official_record_reviews", "official_records"
  add_foreign_key "official_record_reviews", "users"
  add_foreign_key "official_records", "users"
end
