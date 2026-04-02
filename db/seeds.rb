puts "Starting database seeding..."

def truncate_tables!(*tables)
  connection = ActiveRecord::Base.connection
  connection.execute("SET FOREIGN_KEY_CHECKS = 0")
  tables.each do |table_name|
    connection.execute("TRUNCATE TABLE #{table_name}")
  end
  connection.execute("SET FOREIGN_KEY_CHECKS = 1")
end

truncate_tables!(
  "card_actions",
  "homepage_cards",
  "enrollments",
  "academic_classes",
  "enrollment_periods",
  "student_guardians",
  "students",
  "guardians",
  "teachers",
  "student_number_sequences",
  "field_of_studies",
  "degrees",
  "school_years",
  "departments",
  "citizenships",
  "barangays",
  "cities",
  "provinces",
  "regions",
  "countries"
)

seed_files = [
  "locations/base.rb",
  "citizenships.rb",
  "departments.rb",
  "school_years.rb",
  "teachers/teachers.rb",
  "guardians/guardians.rb",
  "academics/base.rb",
  "students/students.rb",
  "homepage_cards.rb"
]

seed_files.each do |file_name|
  file = Rails.root.join("db", "seeds", file_name).to_s
  puts "Processing #{file_name}"
  require file
end

puts "Seeding complete."
