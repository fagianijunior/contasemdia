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

ActiveRecord::Schema[8.1].define(version: 2026_08_25_174350) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "credit_cards", force: :cascade do |t|
    t.string "bank"
    t.integer "closing_day"
    t.datetime "created_at", null: false
    t.integer "due_day"
    t.decimal "limit", precision: 10, scale: 2
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_credit_cards_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.string "category"
    t.datetime "created_at", null: false
    t.integer "credit_card_id"
    t.date "due_date"
    t.string "external_id"
    t.string "fingerprint"
    t.integer "installment"
    t.date "payment_date"
    t.integer "status"
    t.string "title"
    t.integer "total_installments"
    t.integer "transaction_type"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "wallet_id"
    t.index ["credit_card_id"], name: "index_transactions_on_credit_card_id"
    t.index ["external_id"], name: "index_transactions_on_external_id"
    t.index ["fingerprint"], name: "index_transactions_on_fingerprint"
    t.index ["user_id"], name: "index_transactions_on_user_id"
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.decimal "balance", precision: 10, scale: 2
    t.string "bank"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "wallet_type"
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "credit_cards", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "transactions", "credit_cards", on_delete: :cascade
  add_foreign_key "transactions", "users"
  add_foreign_key "transactions", "wallets", on_delete: :cascade
  add_foreign_key "wallets", "users"
end
