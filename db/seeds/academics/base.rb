bsit = Degree.create!(name: "Bachelor of Science in Information Technology", code: "BSIT", description: "Undergraduate program for information technology and systems.")
bsba = Degree.create!(name: "Bachelor of Science in Business Administration", code: "BSBA", description: "Undergraduate program for business and management.")

it_web = FieldOfStudy.create!(degree: bsit, name: "Web and Application Development", code: "IT-WEB", description: "Focus area for web systems and software delivery.")
it_data = FieldOfStudy.create!(degree: bsit, name: "Data and Analytics", code: "IT-DATA", description: "Focus area for data reporting and analytics.")
abm_ops = FieldOfStudy.create!(degree: bsba, name: "Operations Management", code: "BSBA-OPS", description: "Operations and process management specialization.")

school_year = SchoolYear.find_by!(name: "SY 2025-2026")
open_period = EnrollmentPeriod.find_by!(name: "First Semester Enrollment")
teachers = Teacher.order(:id).limit(4)

[
  ["IT101", "Introduction to Computing", 3.0, bsit, it_web, teachers[0], "A", "LAB-201", "Mon/Wed 8:00 AM - 9:30 AM"],
  ["IT205", "Database Systems", 3.0, bsit, it_data, teachers[1], "B", "LAB-305", "Tue/Thu 10:00 AM - 11:30 AM"],
  ["IT310", "Web Systems Project", 3.0, bsit, it_web, teachers[2], "A", "LAB-401", "Fri 1:00 PM - 4:00 PM"],
  ["BA220", "Operations Strategy", 3.0, bsba, abm_ops, teachers[3], "A", "RM-112", "Mon/Wed 1:00 PM - 2:30 PM"]
].each do |class_code, title, units, degree, field_of_study, teacher, section, room, schedule|
  AcademicClass.create!(
    school_year: school_year,
    enrollment_period: open_period,
    degree: degree,
    field_of_study: field_of_study,
    teacher: teacher,
    class_code: class_code,
    title: title,
    units: units,
    section: section,
    room: room,
    schedule: schedule,
    status: "open",
    description: "#{title} active offering for #{school_year.name}."
  )
end
