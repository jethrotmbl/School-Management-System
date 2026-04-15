require "faker"

Faker::Config.locale = :"en-PH"

GUARDIAN_COUNT = 100

def ph_mobile(index)
  "09#{(10 + (index % 90)).to_s.rjust(2, '0')}#{(index + 1).to_s.rjust(7, '0')}"
end

filipino = Citizenship.find_by!(name: "Filipino")
barangays = Barangay.includes(city: { province: { region: :country } }).to_a

raise "No barangays found. Seed locations first." if barangays.empty?

relationships = ["Mother", "Father", "Aunt", "Uncle", "Grandmother", "Grandfather", "Guardian"]
occupations = ["Teacher", "Engineer", "Nurse", "Business Owner", "Government Staff", "Accountant", "Driver", "OFW"]

GUARDIAN_COUNT.times do |index|
  first_name = Faker::Name.first_name
  middle_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  selected_barangay = barangays[index % barangays.length]
  selected_city = selected_barangay.city
  selected_province = selected_city&.province
  selected_region = selected_province&.region
  selected_country = selected_region&.country || Country.find_by!(name: "Philippines")

  sanitized_email_name = "#{first_name}.#{last_name}".downcase.gsub(/[^a-z0-9.]/, "")

  guardian = Guardian.create!(
    first_name: first_name,
    middle_name: middle_name,
    last_name: last_name,
    relationship_to_student: relationships[index % relationships.length],
    email: "#{sanitized_email_name}.guardian#{index + 1}@school.test",
    phone: ph_mobile(index),
    occupation: occupations[index % occupations.length],
    address_line: "#{selected_barangay.name}, #{selected_city&.name}",
    citizenship: filipino,
    country: selected_country,
    region: selected_region,
    province: selected_province,
    city: selected_city,
    barangay: selected_barangay
  )

  attach_seed_profile_image!(
    record: guardian,
    folder_name: "guardians",
    code_prefix: "G",
    image_index: index + 1
  )
end
