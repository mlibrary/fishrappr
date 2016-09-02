# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160902151434) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "issues", force: :cascade do |t|
    t.string   "ht_namespace"
    t.string   "ht_barcode"
    t.string   "volume"
    t.string   "issue_no"
    t.string   "edition"
    t.string   "date_issued"
    t.integer  "issue_sequence", default: 1
    t.integer  "pages_count"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "publication_id"
  end

  add_index "issues", ["id"], name: "index_issues_on_id"
  add_index "issues", ["publication_id"], name: "index_issues_on_publication_id"

  create_table "pages", force: :cascade do |t|
    t.string   "page_no"
    t.integer  "issue_sequence"
    t.string   "text_link"
    t.string   "coordinates_link"
    t.string   "img_link"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "issue_id"
    t.integer  "volume_sequence"
  end

  add_index "pages", ["id"], name: "index_pages_on_id"

  create_table "publications", force: :cascade do |t|
    t.string   "title"
    t.string   "slug"
    t.string   "info_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "publications", ["slug"], name: "index_publications_on_slug", unique: true

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "guest",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
