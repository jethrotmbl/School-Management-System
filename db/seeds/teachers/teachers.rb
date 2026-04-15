require "faker"

Faker::Config.locale = :"en-PH"

TEACHER_COUNT = 50

def ph_mobile(index)
  "09#{(20 + (index % 80)).to_s.rjust(2, '0')}#{(index + 1).to_s.rjust(7, '0')}"
end

filipino = Citizenship.find_by!(name: "Filipino")
departments = Department.order(:id).to_a
city_names = City.order(:name).pluck(:name)

raise "No departments found. Seed departments first." if departments.empty?
raise "No cities found. Seed locations first." if city_names.empty?

specializations = ["Mathematics", "Science", "Programming", "Accounting", "Research", "English", "History", "Physical Education"]
statuses = ["active", "active", "active", "active", "on_leave", "inactive"]

TEACHER_COUNT.times do |index|
  first_name = Faker::Name.first_name
  middle_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  sanitized_email_name = "#{first_name}.#{last_name}".downcase.gsub(/[^a-z0-9.]/, "")

  teacher = Teacher.create!(
    employee_number: "EMP-2026-#{(index + 1).to_s.rjust(4, '0')}",
    first_name: first_name,
    middle_name: middle_name,
    last_name: last_name,
    email: "#{sanitized_email_name}.teacher#{index + 1}@school.test",
    phone: ph_mobile(index),
    status: statuses[index % statuses.length],
    specialization: specializations[index % specializations.length],
    hire_date: Faker::Date.between(from: Date.new(2012, 1, 1), to: Date.new(2025, 12, 31)),
    address_line: "Blk #{(index + 1).to_s.rjust(3, '0')}, #{city_names[index % city_names.length]}",
    department: departments[index % departments.length],
    citizenship: filipino
  )

  attach_seed_profile_image!(
    record: teacher,
    folder_name: "teachers",
    code_prefix: "T",
    image_index: index + 1
  )
end
