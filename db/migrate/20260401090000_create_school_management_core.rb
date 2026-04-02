class CreateSchoolManagementCore < ActiveRecord::Migration[5.2]
  def change
    create_table :citizenships do |t|
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :citizenships, :name, unique: true

    create_table :departments do |t|
      t.string :name, null: false
      t.string :code
      t.text :description
      t.timestamps
    end

    add_index :departments, :name, unique: true
    add_index :departments, :code, unique: true

    create_table :school_years do |t|
      t.string :name, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :status, null: false, default: "planned"
      t.datetime :opened_at
      t.text :description
      t.timestamps
    end

    add_index :school_years, :name, unique: true
    add_index :school_years, :status

    create_table :degrees do |t|
      t.string :name, null: false
      t.string :code
      t.text :description
      t.timestamps
    end

    add_index :degrees, :name, unique: true
    add_index :degrees, :code, unique: true

    create_table :field_of_studies do |t|
      t.references :degree, foreign_key: true
      t.string :name, null: false
      t.string :code
      t.text :description
      t.timestamps
    end

    add_index :field_of_studies, [:degree_id, :name], unique: true
    add_index :field_of_studies, :code, unique: true

    create_table :student_number_sequences do |t|
      t.string :key, null: false
      t.string :prefix, null: false, default: "STU"
      t.integer :last_value, null: false, default: 0
      t.timestamps
    end

    add_index :student_number_sequences, :key, unique: true

    create_table :students do |t|
      t.string :student_number, null: false
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :suffix
      t.date :birth_date
      t.string :gender
      t.string :email
      t.string :phone
      t.string :status, null: false, default: "active"
      t.text :address_line
      t.references :citizenship, foreign_key: true
      t.references :country, foreign_key: true
      t.references :region, foreign_key: true
      t.references :province, foreign_key: true
      t.references :city, foreign_key: true
      t.references :barangay, foreign_key: true
      t.timestamps
    end

    add_index :students, :student_number, unique: true
    add_index :students, :last_name
    add_index :students, :status
    add_index :students, :email

    create_table :guardians do |t|
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :relationship_to_student
      t.string :email
      t.string :phone
      t.string :occupation
      t.text :address_line
      t.references :citizenship, foreign_key: true
      t.references :country, foreign_key: true
      t.references :region, foreign_key: true
      t.references :province, foreign_key: true
      t.references :city, foreign_key: true
      t.references :barangay, foreign_key: true
      t.timestamps
    end

    add_index :guardians, :last_name
    add_index :guardians, :email

    create_table :student_guardians do |t|
      t.references :student, null: false, foreign_key: true
      t.references :guardian, null: false, foreign_key: true
      t.boolean :primary_contact, null: false, default: false
      t.timestamps
    end

    add_index :student_guardians, [:student_id, :guardian_id], unique: true

    create_table :teachers do |t|
      t.string :employee_number, null: false
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :suffix
      t.string :email
      t.string :phone
      t.string :status, null: false, default: "active"
      t.string :specialization
      t.date :hire_date
      t.text :address_line
      t.references :department, foreign_key: true
      t.references :citizenship, foreign_key: true
      t.timestamps
    end

    add_index :teachers, :employee_number, unique: true
    add_index :teachers, :last_name
    add_index :teachers, :email
    add_index :teachers, :status

    create_table :enrollment_periods do |t|
      t.references :school_year, null: false, foreign_key: true
      t.string :name, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :status, null: false, default: "upcoming"
      t.text :description
      t.timestamps
    end

    add_index :enrollment_periods, [:school_year_id, :name], unique: true
    add_index :enrollment_periods, :status

    create_table :academic_classes do |t|
      t.references :school_year, null: false, foreign_key: true
      t.references :enrollment_period, foreign_key: true
      t.references :degree, foreign_key: true
      t.references :field_of_study, foreign_key: true
      t.references :teacher, foreign_key: true
      t.string :class_code, null: false
      t.string :title, null: false
      t.decimal :units, precision: 5, scale: 2, null: false, default: 3.0
      t.string :section
      t.string :room
      t.string :schedule
      t.string :status, null: false, default: "open"
      t.text :description
      t.timestamps
    end

    add_index :academic_classes, :class_code, unique: true
    add_index :academic_classes, :status

    create_table :enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :academic_class, null: false, foreign_key: true
      t.references :school_year, null: false, foreign_key: true
      t.references :enrollment_period, foreign_key: true
      t.string :status, null: false, default: "enrolled"
      t.date :enrolled_on
      t.decimal :final_grade, precision: 5, scale: 2
      t.text :remarks
      t.timestamps
    end

    add_index :enrollments, [:student_id, :academic_class_id, :school_year_id], unique: true, name: "index_enrollments_on_student_class_school_year"
    add_index :enrollments, :status
  end
end
