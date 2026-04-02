filipino = Citizenship.find_by!(name: "Filipino")
departments = Department.order(:id).to_a

10.times do |index|
  Teacher.create!(
    employee_number: "EMP-2026-#{(index + 1).to_s.rjust(4, '0')}",
    first_name: "Teacher#{index + 1}",
    middle_name: "M",
    last_name: "Sample#{index + 1}",
    email: "teacher#{index + 1}@school.test",
    phone: "0917#{(index + 1).to_s.rjust(7, '0')}",
    status: index == 8 ? "on_leave" : "active",
    specialization: ["Mathematics", "Science", "Programming", "Accounting", "Research"][index % 5],
    hire_date: Date.new(2020 + (index % 4), 6, (index % 20) + 1),
    address_line: "Faculty Housing Block #{index + 1}",
    department: departments[index % departments.length],
    citizenship: filipino
  )
end
