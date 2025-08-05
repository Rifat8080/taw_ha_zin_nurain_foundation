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

ActiveRecord::Schema[8.0].define(version: 2025_08_05_131133) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
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
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "donations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount"
    t.uuid "user_id", null: false
    t.uuid "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_donations_on_project_id"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "expenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.integer "amount", null: false
    t.date "date", null: false
    t.uuid "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_expenses_on_project_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount", null: false
    t.uuid "user_id", null: false
    t.uuid "project_id", null: false
    t.string "transaction_id", null: false
    t.string "payment_method", default: "bkash"
    t.string "status", default: "pending"
    t.string "bkash_payment_id"
    t.string "bkash_trx_id"
    t.text "payment_url"
    t.text "callback_url"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bkash_payment_id"], name: "index_payments_on_bkash_payment_id"
    t.index ["project_id"], name: "index_payments_on_project_id"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name"
    t.text "categories"
    t.text "description"
    t.boolean "project_status_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "volunteer_id", null: false
    t.uuid "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_assignments_on_team_id"
    t.index ["volunteer_id"], name: "index_team_assignments_on_volunteer_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "phone_number"
    t.string "email"
    t.text "password_digest"
    t.string "role"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  create_table "volunteers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.date "joining_date", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_volunteers_on_user_id"
  end

  create_table "volunteers_teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.text "district", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "work_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "team_id", null: false
    t.text "title", null: false
    t.text "description", null: false
    t.text "checklist", null: false
    t.date "assigned_date", null: false
    t.uuid "assigned_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by"], name: "index_work_orders_on_assigned_by"
    t.index ["team_id"], name: "index_work_orders_on_team_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "donations", "projects"
  add_foreign_key "donations", "users"
  add_foreign_key "expenses", "projects"
  add_foreign_key "payments", "projects"
  add_foreign_key "payments", "users"
  add_foreign_key "team_assignments", "volunteers"
  add_foreign_key "team_assignments", "volunteers_teams", column: "team_id"
  add_foreign_key "volunteers", "users"
  add_foreign_key "work_orders", "users", column: "assigned_by"
  add_foreign_key "work_orders", "volunteers_teams", column: "team_id"
end
