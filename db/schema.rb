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

ActiveRecord::Schema.define(version: 20170216150553) do

  create_table "comments", force: :cascade do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_comments_on_movie_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.boolean  "stream",      default: false
    t.string   "form"
    t.string   "path"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "imdb"
    t.string   "quality"
  end

  create_table "translates", force: :cascade do |t|
    t.integer  "movie_id"
    t.string   "path"
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_translates_on_movie_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "firstname"
    t.string   "login"
    t.string   "avatar"
    t.string   "provider"
    t.string   "uid"
    t.text     "imageOauthUrl"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "views", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_views_on_movie_id"
    t.index ["user_id"], name: "index_views_on_user_id"
  end

end
