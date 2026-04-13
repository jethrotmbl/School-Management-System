class HomeDashboard
  def resource_cards
    @resource_cards
  end

  def summary_items
    @summary_items
  end

  def load
    @resource_cards = load_resource_cards
    @summary_items = build_summary_items
  end

  
  private
  def load_counts
    {
      "Students" => Student.count,
      "Teachers" => Teacher.count,
      "Guardians" => Guardian.count,
      "School Years" => SchoolYear.count,
      "Academics" => Degree.count + FieldOfStudy.count + AcademicClass.count + Enrollment.count + EnrollmentPeriod.count,
      "Locations" => Country.count + Region.count + Province.count + City.count + Barangay.count + Citizenship.count
    }
  end

  def load_resource_cards
    HomepageCard.includes(:card_actions).order(:position)
  end

  def build_summary_items
    [
      { title: "Students", icon: "user", count: Student.count },
      { title: "Teachers", icon: "clipboard", count: Teacher.count },
      { title: "Guardians", icon: "group", count: Guardian.count },
      { title: "School Years", icon: "calendar-date", count: SchoolYear.count }
    ]
  end
end
