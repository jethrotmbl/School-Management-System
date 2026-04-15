require "faker"

Faker::Config.locale = :"en-PH"

STUDENT_COUNT = 100

def ph_mobile(index)
  "09#{(30 + (index % 70)).to_s.rjust(2, '0')}#{(index + 1).to_s.rjust(7, '0')}"
end

filipino = Citizenship.find_by!(name: "Filipino")
guardians = Guardian.order(:id).to_a
school_year = SchoolYear.find_by!(name: "SY 2025-2026")
enrollment_period = EnrollmentPeriod.find_by!(name: "First Semester Enrollment")
classes = AcademicClass.order(:id).to_a
barangays = Barangay.includes(city: { province: { region: :country } }).to_a

raise "No guardians found. Seed guardians first." if guardians.empty?
raise "No academic classes found. Seed academics first." if classes.empty?
raise "No barangays found. Seed locations first." if barangays.empty?

STUDENT_COUNT.times do |index|
  first_name = Faker::Name.first_name
  middle_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  sanitized_email_name = "#{first_name}.#{last_name}".downcase.gsub(/[^a-z0-9.]/, "")

  selected_barangay = barangays[index % barangays.length]
  selected_city = selected_barangay.city
  selected_province = selected_city&.province
  selected_region = selected_province&.region
  selected_country = selected_region&.country || Country.find_by!(name: "Philippines")

  student = Student.create!(
    first_name: first_name,
    middle_name: middle_name,
    last_name: last_name,
    birth_date: Faker::Date.birthday(min_age: 15, max_age: 22),
    gender: index.even? ? "male" : "female",
    email: "#{sanitized_email_name}.student#{index + 1}@school.test",
    phone: ph_mobile(index),
    status: "active",
    address_line: "#{selected_barangay.name}, #{selected_city&.name}",
    citizenship: filipino,
    country: selected_country,
    region: selected_region,
    province: selected_province,
    city: selected_city,
    barangay: selected_barangay
  )

  attach_seed_profile_image!(
    record: student,
    folder_name: "students",
    code_prefix: "S",
    image_index: index + 1
  )

  primary_guardian = guardians[index % guardians.length]
  secondary_guardian = guardians[(index + (guardians.length / 2)) % guardians.length]

  student.student_guardians.create!(
    guardian: primary_guardian,
    relationship_to_student: primary_guardian.relationship_to_student,
    primary_contact: true
  )

  student.student_guardians.create!(
    guardian: secondary_guardian,
    relationship_to_student: secondary_guardian.relationship_to_student,
    primary_contact: false
  )

  classes.sample([2, classes.length].min).each do |academic_class|
    Enrollment.create!(
      student: student,
      academic_class: academic_class,
      school_year: school_year,
      enrollment_period: enrollment_period,
      status: "enrolled",
      enrolled_on: enrollment_period.starts_on + (index % 20),
      remarks: "Seeded active enrollment."
    )
  end
end
