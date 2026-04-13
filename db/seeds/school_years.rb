school_year_2025 = SchoolYear.create!(
  name: "SY 2025-2026",
  starts_on: Date.new(2025, 6, 1),
  ends_on: Date.new(2026, 4, 15),
  status: "open",
  opened_at: Time.current,
  description: "Current school year used for active enrollment samples."
)

school_year_2024 = SchoolYear.create!(
  name: "SY 2024-2025",
  starts_on: Date.new(2024, 6, 1),
  ends_on: Date.new(2025, 4, 15),
  status: "closed",
  description: "Previous school year kept for historical records."
)

school_year_2025.enrollment_periods.ordered.first.update!(
  name: "First Semester Enrollment",
  starts_on: Date.new(2025, 5, 2),
  ends_on: Date.new(2025, 6, 15),
  status: "active",
  description: "Main onboarding period for first semester."
)

school_year_2025.enrollment_periods.ordered.second.update!(
  name: "Second Semester Enrollment",
  starts_on: Date.new(2025, 10, 20),
  ends_on: Date.new(2025, 11, 30),
  status: "planning",
  description: "Second semester enrollment window."
)

school_year_2024.enrollment_periods.ordered.first.update!(
  name: "Historical Enrollment",
  starts_on: Date.new(2024, 5, 2),
  ends_on: Date.new(2024, 6, 15),
  status: "completed",
  description: "Closed sample period."
)
