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

ActiveRecord::Schema[8.1].define(version: 2026_07_11_140003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ai_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "api_key"
    t.datetime "created_at", null: false
    t.string "model_id", default: "claude-opus-4-8", null: false
    t.datetime "updated_at", null: false
  end

  create_table "factions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color", default: "#7a7a7a", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_active", default: true
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "fallacy_definitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.float "default_confidence_threshold", default: 0.6, null: false
    t.boolean "default_enabled", default: true, null: false
    t.integer "default_severity", default: 1, null: false
    t.text "detection_prompt_fragment", null: false
    t.string "display_name", null: false
    t.string "key", null: false
    t.text "long_description", null: false
    t.text "short_description", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_fallacy_definitions_on_key", unique: true
  end

  create_table "fallacy_flags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.float "confidence", null: false
    t.datetime "created_at", null: false
    t.boolean "dismissed_by_author", default: false, null: false
    t.text "excerpt", null: false
    t.uuid "fallacy_definition_id", null: false
    t.uuid "flaggable_id", null: false
    t.string "flaggable_type", null: false
    t.boolean "visible_publicly", default: false, null: false
    t.index ["flaggable_type", "flaggable_id"], name: "index_fallacy_flags_on_flaggable_type_and_flaggable_id"
  end

  create_table "fallacy_scope_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.float "confidence_threshold"
    t.datetime "created_at", null: false
    t.boolean "enabled"
    t.uuid "fallacy_definition_id", null: false
    t.uuid "scope_id", null: false
    t.string "scope_type", null: false
    t.datetime "updated_at", null: false
    t.index ["fallacy_definition_id", "scope_type", "scope_id"], name: "index_fallacy_scope_settings_uniqueness", unique: true
    t.index ["scope_type", "scope_id"], name: "index_fallacy_scope_settings_on_scope_type_and_scope_id"
  end

  create_table "forum_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "affiliation_factor", default: "1.0"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "index_order"
    t.boolean "is_visible", default: true
    t.string "slug", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_forum_categories_on_slug", unique: true
  end

  create_table "forum_threads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "can_be_replied_to", default: true
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.uuid "forum_id", null: false
    t.boolean "includes_poll", default: false
    t.boolean "is_draft", default: true
    t.boolean "is_sticky", default: false
    t.boolean "is_visible", default: true
    t.string "slug", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["forum_id"], name: "index_forum_threads_on_forum_id"
    t.index ["slug"], name: "index_forum_threads_on_slug", unique: true
    t.index ["user_id"], name: "index_forum_threads_on_user_id"
  end

  create_table "forums", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "affiliation_factor", default: "1.0"
    t.datetime "created_at", null: false
    t.text "description"
    t.uuid "forum_category_id", null: false
    t.integer "index_order"
    t.boolean "is_visible", default: true
    t.string "slug", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["forum_category_id"], name: "index_forums_on_forum_category_id"
    t.index ["slug"], name: "index_forums_on_slug", unique: true
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.uuid "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "thread_replies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "can_be_quoted", default: true
    t.datetime "created_at", null: false
    t.uuid "forum_thread_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["forum_thread_id"], name: "index_thread_replies_on_forum_thread_id"
    t.index ["user_id"], name: "index_thread_replies_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.uuid "faction_id"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "show_my_fallacy_flags_publicly", default: false, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["faction_id"], name: "index_users_on_faction_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.uuid "role_id"
    t.uuid "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "fallacy_flags", "fallacy_definitions"
  add_foreign_key "fallacy_scope_settings", "fallacy_definitions"
  add_foreign_key "forum_threads", "forums"
  add_foreign_key "forum_threads", "users"
  add_foreign_key "forums", "forum_categories"
  add_foreign_key "thread_replies", "forum_threads"
  add_foreign_key "thread_replies", "users"
  add_foreign_key "users", "factions"
  add_foreign_key "users_roles", "roles"
  add_foreign_key "users_roles", "users"
end
