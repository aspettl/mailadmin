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

ActiveRecord::Schema.define(version: 2021_06_05_094041) do

  create_table "accounts", charset: "utf8mb4", force: :cascade do |t|
    t.string "email"
    t.string "crypt"
    t.bigint "domain_id", null: false
    t.boolean "enabled"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "forward", default: false, null: false
    t.string "forward_to"
    t.integer "type", default: 0, null: false
    t.string "alias_target"
    t.index ["domain_id"], name: "index_accounts_on_domain_id"
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["type", "alias_target"], name: "index_accounts_on_type_and_alias_target"
    t.index ["type", "forward", "forward_to"], name: "index_accounts_on_type_and_forward_and_forward_to"
  end

  create_table "domains", charset: "utf8mb4", force: :cascade do |t|
    t.string "domain"
    t.bigint "user_id", null: false
    t.boolean "enabled"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "type", default: 0, null: false
    t.string "alias_target"
    t.boolean "catchall", default: false, null: false
    t.string "catchall_target"
    t.index ["domain"], name: "index_domains_on_domain", unique: true
    t.index ["type", "catchall", "catchall_target"], name: "index_domains_on_type_and_catchall_and_catchall_target"
    t.index ["user_id"], name: "index_domains_on_user_id"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accounts", "domains"
  add_foreign_key "domains", "users"
end
