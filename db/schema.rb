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

ActiveRecord::Schema.define(version: 20170914222634) do

  create_table "good_activities", force: :cascade do |t|
    t.string "name"
    t.integer "good_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["good_stage_id"], name: "index_good_activities_on_good_stage_id"
  end

  create_table "good_stages", force: :cascade do |t|
    t.string "name"
    t.integer "months"
    t.integer "days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "goods", force: :cascade do |t|
    t.string "credit_id"
    t.string "socio_id"
    t.string "nombres"
    t.string "cedula"
    t.string "telefono"
    t.string "celular"
    t.string "direccion"
    t.string "sector"
    t.string "parroquia"
    t.string "canton"
    t.string "nombre_grupo"
    t.string "grupo_solidario"
    t.string "sucursal"
    t.string "oficial_credito"
    t.string "cartera_heredada"
    t.string "fecha_concesion"
    t.string "fecha_vencimiento"
    t.string "tipo_garantia"
    t.string "garantia_real"
    t.string "garantia_fiduciaria"
    t.string "dir_garante"
    t.string "tel_garante"
    t.string "valor_cartera_castigada"
    t.string "bienes"
    t.string "tipo_credito"
    t.integer "good_stage_id"
    t.integer "good_activity_id"
    t.string "estado"
    t.text "observaciones"
    t.string "juicio_id"
    t.date "fentrega_juicios"
    t.date "fcalificacion_juicio"
    t.string "codigo_juicio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lawyer_id"
    t.string "fecha_terminacion"
    t.index ["good_activity_id"], name: "index_goods_on_good_activity_id"
    t.index ["good_stage_id"], name: "index_goods_on_good_stage_id"
    t.index ["lawyer_id"], name: "index_goods_on_lawyer_id"
  end

  create_table "history_credits", force: :cascade do |t|
    t.string "credit_id"
    t.string "socio_id"
    t.string "cedula"
    t.string "agencia"
    t.string "abogado"
    t.string "asesor"
    t.string "estado"
    t.string "semaforo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mes"
    t.string "tipo_credito"
  end

  create_table "insolvencies", force: :cascade do |t|
    t.string "credit_id"
    t.string "socio_id"
    t.string "nombres"
    t.string "cedula"
    t.string "telefono"
    t.string "celular"
    t.string "direccion"
    t.string "sector"
    t.string "parroquia"
    t.string "canton"
    t.string "nombre_grupo"
    t.string "grupo_solidario"
    t.string "sucursal"
    t.string "oficial_credito"
    t.string "cartera_heredada"
    t.string "fecha_concesion"
    t.string "fecha_vencimiento"
    t.string "tipo_garantia"
    t.string "garantia_real"
    t.string "garantia_fiduciaria"
    t.string "dir_garante"
    t.string "tel_garante"
    t.string "valor_cartera_castigada"
    t.string "bienes"
    t.string "tipo_credito"
    t.integer "insolvency_stage_id"
    t.integer "insolvency_activity_id"
    t.string "estado"
    t.text "observaciones"
    t.string "juicio_id"
    t.date "fentrega_juicios"
    t.date "fcalificacion_juicio"
    t.string "codigo_juicio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lawyer_id"
    t.string "fecha_terminacion"
    t.index ["insolvency_activity_id"], name: "index_insolvencies_on_insolvency_activity_id"
    t.index ["insolvency_stage_id"], name: "index_insolvencies_on_insolvency_stage_id"
    t.index ["lawyer_id"], name: "index_insolvencies_on_lawyer_id"
  end

  create_table "insolvency_activities", force: :cascade do |t|
    t.string "name"
    t.integer "insolvency_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insolvency_stage_id"], name: "index_insolvency_activities_on_insolvency_stage_id"
  end

  create_table "insolvency_stages", force: :cascade do |t|
    t.string "name"
    t.integer "months"
    t.integer "days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lawyers", force: :cascade do |t|
    t.string "name"
    t.string "lastname"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pending_trials", force: :cascade do |t|
    t.string "credit_id"
    t.string "socio_id"
    t.string "nombres"
    t.string "cedula"
    t.string "telefono"
    t.string "celular"
    t.string "direccion"
    t.string "sector"
    t.string "parroquia"
    t.string "canton"
    t.string "nombre_grupo"
    t.string "grupo_solidario"
    t.string "sucursal"
    t.string "oficial_credito"
    t.string "cartera_heredada"
    t.string "fecha_concesion"
    t.string "fecha_vencimiento"
    t.string "tipo_garantia"
    t.string "garantia_real"
    t.string "garantia_fiduciaria"
    t.string "dir_garante"
    t.string "tel_garante"
    t.string "valor_cartera_castigada"
    t.string "bienes"
    t.string "tipo_credito"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "calificacion_propia"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "lastname"
    t.string "rol"
    t.integer "permissions"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "without_good_activities", force: :cascade do |t|
    t.string "name"
    t.integer "withoutgood_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["withoutgood_stage_id"], name: "index_without_good_activities_on_withoutgood_stage_id"
  end

  create_table "without_goods", force: :cascade do |t|
    t.string "credit_id"
    t.string "socio_id"
    t.string "nombres"
    t.string "cedula"
    t.string "telefono"
    t.string "celular"
    t.string "direccion"
    t.string "sector"
    t.string "parroquia"
    t.string "canton"
    t.string "nombre_grupo"
    t.string "grupo_solidario"
    t.string "sucursal"
    t.string "oficial_credito"
    t.string "cartera_heredada"
    t.string "fecha_concesion"
    t.string "fecha_vencimiento"
    t.string "tipo_garantia"
    t.string "garantia_real"
    t.string "garantia_fiduciaria"
    t.string "dir_garante"
    t.string "tel_garante"
    t.string "valor_cartera_castigada"
    t.string "bienes"
    t.string "tipo_credito"
    t.integer "withoutgood_stage_id"
    t.integer "without_good_activity_id"
    t.string "estado"
    t.text "observaciones"
    t.string "juicio_id"
    t.date "fentrega_juicios"
    t.date "fcalificacion_juicio"
    t.string "codigo_juicio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lawyer_id"
    t.string "fecha_terminacion"
    t.index ["lawyer_id"], name: "index_without_goods_on_lawyer_id"
    t.index ["without_good_activity_id"], name: "index_without_goods_on_without_good_activity_id"
    t.index ["withoutgood_stage_id"], name: "index_without_goods_on_withoutgood_stage_id"
  end

  create_table "withoutgood_stages", force: :cascade do |t|
    t.string "name"
    t.integer "months"
    t.integer "days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
