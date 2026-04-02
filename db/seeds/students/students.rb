filipino = Citizenship.find_by!(name: "Filipino")
country = Country.find_by!(name: "Philippines")
region = Region.find_by!(name: "National Capital Region")
province = Province.find_by!(name: "Metro Manila")
city = City.find_by!(name: "Quezon City")
barangay = Barangay.find_by!(name: "Commonwealth")
guardians = Guardian.order(:id).to_a
school_year = SchoolYear.find_by!(name: "SY 2025-2026")
enrollment_period = EnrollmentPeriod.find_by!(name: "First Semester Enrollment")
classes = AcademicClass.order(:id).to_a

10.times do |index|
  student = Student.create!(
    first_name: "Student#{index + 1}",
    middle_name: "K",
    last_name: "Learner#{index + 1}",
    birth_date: Date.new(2007, (index % 12) + 1, [index + 1, 28].min),
    gender: index.even? ? "male" : "female",
    email: "student#{index + 1}@school.test",
    phone: "0939#{(index + 1).to_s.rjust(7, '0')}",
    status: "active",
    address_line: "Student Residence #{index + 1}, Quezon City",
    citizenship: filipino,
    country: country,
    region: region,
    province: province,
    city: city,
    barangay: barangay
  )

  student.guardians << guardians[index]
  student.guardians << guardians[(index + 1) % guardians.length]

  classes.sample(2).each do |academic_class|
    Enrollment.create!(
      student: student,
      academic_class: academic_class,
      school_year: school_year,
      enrollment_period: enrollment_period,
      status: "enrolled",
      enrolled_on: Date.new(2025, 6, [index + 1, 28].min),
      remarks: "Seeded active enrollment."
    )
  end
end
