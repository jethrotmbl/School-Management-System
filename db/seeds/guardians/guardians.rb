filipino = Citizenship.find_by!(name: "Filipino")
country = Country.find_by!(name: "Philippines")
region = Region.find_by!(name: "National Capital Region")
province = Province.find_by!(name: "Metro Manila")
city = City.find_by!(name: "Quezon City")
barangay = Barangay.find_by!(name: "Bagumbayan")

10.times do |index|
  Guardian.create!(
    first_name: "Guardian#{index + 1}",
    middle_name: "L",
    last_name: "Family#{index + 1}",
    relationship_to_student: ["Mother", "Father", "Aunt", "Uncle", "Grandmother"][index % 5],
    email: "guardian#{index + 1}@school.test",
    phone: "0928#{(index + 1).to_s.rjust(7, '0')}",
    occupation: ["Teacher", "Engineer", "Nurse", "Business Owner", "Government Staff"][index % 5],
    address_line: "Guardian Residence #{index + 1}, Quezon City",
    citizenship: filipino,
    country: country,
    region: region,
    province: province,
    city: city,
    barangay: barangay
  )
end
