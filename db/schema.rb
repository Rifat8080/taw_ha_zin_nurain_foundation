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

ActiveRecord::Schema[8.0].define(version: 2025_08_07_074637) do
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

  create_table "assets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "zakat_calculation_id", null: false
    t.string "category", null: false
    t.text "description"
    t.decimal "amount", precision: 14, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_assets_on_category"
    t.index ["zakat_calculation_id"], name: "index_assets_on_zakat_calculation_id"
    t.check_constraint "amount >= 0::numeric", name: "check_amount_positive"
    t.check_constraint "category::text = ANY (ARRAY['cash'::character varying, 'bank'::character varying, 'gold'::character varying, 'silver'::character varying, 'business_inventory'::character varying, 'receivables'::character varying, 'livestock'::character varying, 'agriculture'::character varying, 'investments'::character varying, 'property_rent'::character varying]::text[])", name: "check_category"
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

  create_table "event_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "event_id", null: false
    t.string "ticket_code", null: false
    t.string "status", default: "registered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_users_on_event_id"
    t.index ["status"], name: "index_event_users_on_status"
    t.index ["ticket_code"], name: "index_event_users_on_ticket_code", unique: true
    t.index ["user_id", "event_id"], name: "index_event_users_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_event_users_on_user_id"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "seat_number", null: false
    t.text "venue", null: false
    t.text "guest_list"
    t.text "guest_description"
    t.integer "ticket_price", null: false
    t.string "ticket_category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["start_date"], name: "index_events_on_start_date"
    t.index ["ticket_category"], name: "index_events_on_ticket_category"
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

  create_table "healthcare_donations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "request_id", null: false
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amount"], name: "index_healthcare_donations_on_amount"
    t.index ["request_id"], name: "index_healthcare_donations_on_request_id"
    t.index ["user_id"], name: "index_healthcare_donations_on_user_id"
  end

  create_table "healthcare_expenses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "healthcare_request_id", null: false
    t.uuid "user_id", null: false
    t.string "description", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "category"
    t.text "notes"
    t.string "receipt_url"
    t.date "expense_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_date"], name: "index_healthcare_expenses_on_expense_date"
    t.index ["healthcare_request_id"], name: "index_healthcare_expenses_on_healthcare_request_id"
    t.index ["user_id"], name: "index_healthcare_expenses_on_user_id"
  end

  create_table "healthcare_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.text "patient_name", null: false
    t.text "reason", null: false
    t.text "prescription_url"
    t.string "status", default: "pending"
    t.boolean "approved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved"], name: "index_healthcare_requests_on_approved"
    t.index ["status"], name: "index_healthcare_requests_on_status"
    t.index ["user_id"], name: "index_healthcare_requests_on_user_id"
  end

  create_table "liabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "zakat_calculation_id", null: false
    t.text "description"
    t.decimal "amount", precision: 14, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["zakat_calculation_id"], name: "index_liabilities_on_zakat_calculation_id"
    t.check_constraint "amount >= 0::numeric", name: "check_amount_positive"
  end

  create_table "nisab_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "year", null: false
    t.decimal "gold_price_per_gram", precision: 8, scale: 2, null: false
    t.decimal "silver_price_per_gram", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "nisab_gold", type: :decimal, precision: 14, scale: 2, as: "(gold_price_per_gram * (85)::numeric)", stored: true
    t.virtual "nisab_silver", type: :decimal, precision: 14, scale: 2, as: "(silver_price_per_gram * (595)::numeric)", stored: true
    t.index ["year"], name: "index_nisab_rates_on_year", unique: true
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

  create_table "tickets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "event_id", null: false
    t.uuid "user_id", null: false
    t.string "qr_code", null: false
    t.string "ticket_type", null: false
    t.integer "price", null: false
    t.string "status", default: "active"
    t.string "seat_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "seat_number"], name: "index_tickets_on_event_id_and_seat_number", unique: true
    t.index ["event_id"], name: "index_tickets_on_event_id"
    t.index ["qr_code"], name: "index_tickets_on_qr_code", unique: true
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["ticket_type"], name: "index_tickets_on_ticket_type"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "phone_number"
    t.string "email"
    t.string "role"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
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

  create_table "zakat_calculations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.integer "calculation_year", null: false
    t.decimal "total_assets", precision: 14, scale: 2, default: "0.0"
    t.decimal "total_liabilities", precision: 14, scale: 2, default: "0.0"
    t.decimal "nisab_value", precision: 14, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "net_assets", type: :decimal, precision: 14, scale: 2, as: "(total_assets - total_liabilities)", stored: true
    t.virtual "zakat_due", type: :decimal, precision: 14, scale: 2, as: "\nCASE\n    WHEN ((total_assets - total_liabilities) >= nisab_value) THEN round(((total_assets - total_liabilities) * 0.025), 2)\n    ELSE (0)::numeric\nEND", stored: true
    t.index ["user_id", "calculation_year"], name: "index_zakat_calculations_on_user_id_and_calculation_year", unique: true
    t.index ["user_id"], name: "index_zakat_calculations_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assets", "zakat_calculations"
  add_foreign_key "donations", "projects"
  add_foreign_key "donations", "users"
  add_foreign_key "event_users", "events"
  add_foreign_key "event_users", "users"
  add_foreign_key "expenses", "projects"
  add_foreign_key "healthcare_donations", "healthcare_requests", column: "request_id"
  add_foreign_key "healthcare_donations", "users"
  add_foreign_key "healthcare_expenses", "healthcare_requests"
  add_foreign_key "healthcare_expenses", "users"
  add_foreign_key "healthcare_requests", "users"
  add_foreign_key "liabilities", "zakat_calculations"
  add_foreign_key "payments", "projects"
  add_foreign_key "payments", "users"
  add_foreign_key "team_assignments", "volunteers"
  add_foreign_key "team_assignments", "volunteers_teams", column: "team_id"
  add_foreign_key "tickets", "events"
  add_foreign_key "tickets", "users"
  add_foreign_key "volunteers", "users"
  add_foreign_key "work_orders", "users", column: "assigned_by"
  add_foreign_key "work_orders", "volunteers_teams", column: "team_id"
  add_foreign_key "zakat_calculations", "users"
end
