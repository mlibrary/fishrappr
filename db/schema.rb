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

ActiveRecord::Schema[7.1].define(version: 2024_06_14_150244) do
  create_table "bookmarks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type", limit: 255
    t.string "document_id", limit: 255
    t.string "title", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "document_type", limit: 255
    t.index ["user_id"], name: "bookmarks_index_bookmarks_on_user_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string "volume_identifier", limit: 255
    t.string "issue_identifier", limit: 255
    t.integer "publication_year"
    t.string "publication_title", limit: 255
    t.string "volume", limit: 255
    t.string "issue_number", limit: 255
    t.string "edition", limit: 255
    t.string "date_issued", limit: 255
    t.integer "variant_sequence", default: 1
    t.integer "pages_count"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "publication_id"
    t.index ["id"], name: "issues_index_issues_on_id"
    t.index ["issue_identifier"], name: "issues_index_issues_on_issue_identifier"
    t.index ["publication_id"], name: "issues_index_issues_on_publication_id"
    t.index ["volume_identifier"], name: "issues_index_issues_on_volume_identifier"
  end

  create_table "pages", force: :cascade do |t|
    t.string "page_number", limit: 255
    t.integer "issue_sequence"
    t.integer "volume_sequence"
    t.string "text_link", limit: 255
    t.string "coordinates_link", limit: 255
    t.string "image_link", limit: 255
    t.string "page_identifier", limit: 255
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "issue_id"
    t.string "page_label", limit: 255
    t.index ["id"], name: "pages_index_pages_on_id"
    t.index ["issue_id"], name: "pages_fk_rails_090dfefe4e"
    t.index ["page_label"], name: "pages_index_pages_on_page_label"
  end

  create_table "publications", force: :cascade do |t|
    t.string "title", limit: 255
    t.string "slug", limit: 255
    t.string "info_link", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "first_print_year"
    t.integer "last_print_year"
    t.index ["slug"], name: "publications_index_publications_on_slug", unique: true
  end

  create_table "searches", force: :cascade do |t|
    t.text "query_params"
    t.integer "user_id"
    t.string "user_type", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "searches_index_searches_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "guest", default: false
    t.index ["email"], name: "users_index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "users_index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "issues", "publications"
  add_foreign_key "pages", "issues"
end
