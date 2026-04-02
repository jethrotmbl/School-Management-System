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

ActiveRecord::Schema.define(version: 2026_04_01_090000) do

  create_table "academic_classes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "school_year_id", null: false
    t.bigint "enrollment_period_id"
    t.bigint "degree_id"
    t.bigint "field_of_study_id"
    t.bigint "teacher_id"
    t.string "class_code", null: false
    t.string "title", null: false
    t.decimal "units", precision: 5, scale: 2, default: "3.0", null: false
    t.string "section"
    t.string "room"
    t.string "schedule"
    t.string "status", default: "open", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_code"], name: "index_academic_classes_on_class_code", unique: true
    t.index ["degree_id"], name: "index_academic_classes_on_degree_id"
    t.index ["enrollment_period_id"], name: "index_academic_classes_on_enrollment_period_id"
    t.index ["field_of_study_id"], name: "index_academic_classes_on_field_of_study_id"
    t.index ["school_year_id"], name: "index_academic_classes_on_school_year_id"
    t.index ["status"], name: "index_academic_classes_on_status"
    t.index ["teacher_id"], name: "index_academic_classes_on_teacher_id"
  end

  create_table "barangays", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "city_id"
    t.index ["city_id"], name: "index_barangays_on_city_id"
  end

  create_table "card_actions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "homepage_card_id"
    t.string "label"
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["homepage_card_id", "position"], name: "index_card_actions_on_homepage_card_id_and_position"
    t.index ["homepage_card_id"], name: "index_card_actions_on_homepage_card_id"
  end

  create_table "cities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "remarks"
    t.boolean "is_municipality"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "province_id"
    t.index ["province_id"], name: "index_cities_on_province_id"
  end

  create_table "citizenships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_citizenships_on_name", unique: true
  end

  create_table "countries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "degrees", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_degrees_on_code", unique: true
    t.index ["name"], name: "index_degrees_on_name", unique: true
  end

  create_table "departments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "enrollment_periods", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "school_year_id", null: false
    t.string "name", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.string "status", default: "upcoming", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_year_id", "name"], name: "index_enrollment_periods_on_school_year_id_and_name", unique: true
    t.index ["school_year_id"], name: "index_enrollment_periods_on_school_year_id"
    t.index ["status"], name: "index_enrollment_periods_on_status"
  end

  create_table "enrollments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "academic_class_id", null: false
    t.bigint "school_year_id", null: false
    t.bigint "enrollment_period_id"
    t.string "status", default: "enrolled", null: false
    t.date "enrolled_on"
    t.decimal "final_grade", precision: 5, scale: 2
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_class_id"], name: "index_enrollments_on_academic_class_id"
    t.index ["enrollment_period_id"], name: "index_enrollments_on_enrollment_period_id"
    t.index ["school_year_id"], name: "index_enrollments_on_school_year_id"
    t.index ["status"], name: "index_enrollments_on_status"
    t.index ["student_id", "academic_class_id", "school_year_id"], name: "index_enrollments_on_student_class_school_year", unique: true
    t.index ["student_id"], name: "index_enrollments_on_student_id"
  end

  create_table "field_of_studies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "degree_id"
    t.string "name", null: false
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_field_of_studies_on_code", unique: true
    t.index ["degree_id", "name"], name: "index_field_of_studies_on_degree_id_and_name", unique: true
    t.index ["degree_id"], name: "index_field_of_studies_on_degree_id"
  end

  create_table "guardians", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "relationship_to_student"
    t.string "email"
    t.string "phone"
    t.string "occupation"
    t.text "address_line"
    t.bigint "citizenship_id"
    t.bigint "country_id"
    t.bigint "region_id"
    t.bigint "province_id"
    t.bigint "city_id"
    t.bigint "barangay_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_id"], name: "index_guardians_on_barangay_id"
    t.index ["citizenship_id"], name: "index_guardians_on_citizenship_id"
    t.index ["city_id"], name: "index_guardians_on_city_id"
    t.index ["country_id"], name: "index_guardians_on_country_id"
    t.index ["email"], name: "index_guardians_on_email"
    t.index ["last_name"], name: "index_guardians_on_last_name"
    t.index ["province_id"], name: "index_guardians_on_province_id"
    t.index ["region_id"], name: "index_guardians_on_region_id"
  end

  create_table "homepage_cards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "position"
    t.index ["position"], name: "index_homepage_cards_on_position"
  end

  create_table "provinces", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.index ["region_id"], name: "index_provinces_on_region_id"
  end

  create_table "regions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "country_id"
    t.index ["country_id"], name: "index_regions_on_country_id"
  end

  create_table "school_years", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.string "status", default: "planned", null: false
    t.datetime "opened_at"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_school_years_on_name", unique: true
    t.index ["status"], name: "index_school_years_on_status"
  end

  create_table "student_guardians", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "guardian_id", null: false
    t.boolean "primary_contact", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guardian_id"], name: "index_student_guardians_on_guardian_id"
    t.index ["student_id", "guardian_id"], name: "index_student_guardians_on_student_id_and_guardian_id", unique: true
    t.index ["student_id"], name: "index_student_guardians_on_student_id"
  end

  create_table "student_number_sequences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "prefix", default: "STU", null: false
    t.integer "last_value", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_student_number_sequences_on_key", unique: true
  end

  create_table "students", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "student_number", null: false
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "suffix"
    t.date "birth_date"
    t.string "gender"
    t.string "email"
    t.string "phone"
    t.string "status", default: "active", null: false
    t.text "address_line"
    t.bigint "citizenship_id"
    t.bigint "country_id"
    t.bigint "region_id"
    t.bigint "province_id"
    t.bigint "city_id"
    t.bigint "barangay_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barangay_id"], name: "index_students_on_barangay_id"
    t.index ["citizenship_id"], name: "index_students_on_citizenship_id"
    t.index ["city_id"], name: "index_students_on_city_id"
    t.index ["country_id"], name: "index_students_on_country_id"
    t.index ["email"], name: "index_students_on_email"
    t.index ["last_name"], name: "index_students_on_last_name"
    t.index ["province_id"], name: "index_students_on_province_id"
    t.index ["region_id"], name: "index_students_on_region_id"
    t.index ["status"], name: "index_students_on_status"
    t.index ["student_number"], name: "index_students_on_student_number", unique: true
  end

  create_table "teachers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "employee_number", null: false
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "suffix"
    t.string "email"
    t.string "phone"
    t.string "status", default: "active", null: false
    t.string "specialization"
    t.date "hire_date"
    t.text "address_line"
    t.bigint "department_id"
    t.bigint "citizenship_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["citizenship_id"], name: "index_teachers_on_citizenship_id"
    t.index ["department_id"], name: "index_teachers_on_department_id"
    t.index ["email"], name: "index_teachers_on_email"
    t.index ["employee_number"], name: "index_teachers_on_employee_number", unique: true
    t.index ["last_name"], name: "index_teachers_on_last_name"
    t.index ["status"], name: "index_teachers_on_status"
  end

  add_foreign_key "academic_classes", "degrees"
  add_foreign_key "academic_classes", "enrollment_periods"
  add_foreign_key "academic_classes", "field_of_studies"
  add_foreign_key "academic_classes", "school_years"
  add_foreign_key "academic_classes", "teachers"
  add_foreign_key "barangays", "cities"
  add_foreign_key "card_actions", "homepage_cards"
  add_foreign_key "cities", "provinces"
  add_foreign_key "enrollment_periods", "school_years"
  add_foreign_key "enrollments", "academic_classes"
  add_foreign_key "enrollments", "enrollment_periods"
  add_foreign_key "enrollments", "school_years"
  add_foreign_key "enrollments", "students"
  add_foreign_key "field_of_studies", "degrees"
  add_foreign_key "guardians", "barangays"
  add_foreign_key "guardians", "cities"
  add_foreign_key "guardians", "citizenships"
  add_foreign_key "guardians", "countries"
  add_foreign_key "guardians", "provinces"
  add_foreign_key "guardians", "regions"
  add_foreign_key "provinces", "regions"
  add_foreign_key "regions", "countries"
  add_foreign_key "student_guardians", "guardians"
  add_foreign_key "student_guardians", "students"
  add_foreign_key "students", "barangays"
  add_foreign_key "students", "cities"
  add_foreign_key "students", "citizenships"
  add_foreign_key "students", "countries"
  add_foreign_key "students", "provinces"
  add_foreign_key "students", "regions"
  add_foreign_key "teachers", "citizenships"
  add_foreign_key "teachers", "departments"
end
