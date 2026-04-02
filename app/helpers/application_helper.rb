module ApplicationHelper
  def kendo_icon(name, classes: nil, label: nil)
    attributes = {
      class: ["k-icon", "k-i-#{name}", classes].compact.join(" "),
      role: (label.present? ? "img" : "presentation"),
      "aria-hidden": label.present? ? nil : true,
      "aria-label": label
    }.compact

    content_tag(:span, nil, **attributes)
  end

  def safe_return_path(fallback)
    return_to = params[:return_to].to_s
    return fallback unless return_to.start_with?("/")

    return_to
  end

  def drawer_navigation_items
    [
      { key: "home", label: "Home", path: root_path, icon: "home" },
      {
        key: "students",
        label: "Students",
        path: students_path,
        icon: "user",
        children: [
          { key: "students-index", label: "All Students", path: students_path },
          { key: "students-search", label: "Search Students", path: search_students_path }
        ]
      },
      {
        key: "teachers",
        label: "Teachers",
        path: teachers_path,
        icon: "user-group",
        children: [
          { key: "teachers-index", label: "All Teachers", path: teachers_path },
          { key: "teachers-search", label: "Search Teachers", path: search_teachers_path },
          { key: "departments-index", label: "Departments", path: departments_path }
        ]
      },
      {
        key: "guardians",
        label: "Guardians",
        path: guardians_path,
        icon: "group",
        children: [
          { key: "guardians-index", label: "All Guardians", path: guardians_path },
          { key: "guardians-search", label: "Search Guardians", path: search_guardians_path }
        ]
      },
      {
        key: "school_years",
        label: "School Years",
        path: school_years_path,
        icon: "calendar-date",
        children: [
          { key: "school_years-index", label: "All School Years", path: school_years_path },
          { key: "school_years-new", label: "Open School Year", path: new_school_year_path(open_now: 1) }
        ]
      },
      {
        key: "degrees",
        label: "Academics",
        path: degrees_path,
        icon: "book",
        children: [
          { key: "degrees-index", label: "Degrees", path: degrees_path },
          { key: "field_of_studies-index", label: "Field of Study", path: field_of_studies_path },
          { key: "academic_classes-index", label: "Classes", path: academic_classes_path },
          { key: "enrollments-index", label: "Enrollments", path: enrollments_path },
          { key: "enrollment_periods-index", label: "Enrollment Periods", path: enrollment_periods_path }
        ]
      },
      {
        key: "countries",
        label: "Locations",
        path: countries_path,
        icon: "globe",
        children: [
          { key: "countries-index", label: "All Countries", path: countries_path },
          { key: "regions-index", label: "Regions", path: regions_path },
          { key: "provinces-index", label: "Provinces", path: provinces_path },
          { key: "cities-index", label: "Cities", path: cities_path },
          { key: "barangays-index", label: "Barangays", path: barangays_path },
          { key: "citizenships-index", label: "Citizenship", path: citizenships_path }
        ]
      }
    ]
  end

  def current_drawer_key
    return "home" if controller_name == "home"

    case controller_name
    when "departments"
      "teachers"
    when "field_of_studies", "academic_classes", "enrollments", "enrollment_periods"
      "degrees"
    when "regions", "provinces", "cities", "barangays", "citizenships"
      "countries"
    else
      controller_name
    end
  end

  def current_drawer_child_key
    return nil if controller_name == "home"

    case action_name
    when "index"
      "#{controller_name}-index"
    when "search"
      "#{controller_name}-search"
    when "new", "create"
      "#{controller_name}-new"
    else
      nil
    end
  end

  def resource_grid_render(record, renderer, fallback: "-")
    return fallback unless renderer.respond_to?(:call)

    value = instance_exec(record, &renderer)
    return fallback if value.nil?
    return fallback if value.respond_to?(:empty?) && value.empty?

    value
  end

  def resource_grid_actions(record, view_path:, edit_path:, delete_path:, delete_confirm: "Are you sure?")
    content_tag(:div, class: "resource-grid-actions") do
      safe_join(
        [
          link_to("View", view_path, class: "btn btn-sm btn-outline-secondary"),
          link_to("Edit", edit_path, class: "btn btn-sm btn-outline-brand"),
          link_to(
            "Delete",
            delete_path,
            method: :delete,
            data: { confirm: delete_confirm },
            class: "btn btn-sm btn-outline-danger"
          )
        ]
      )
    end
  end

  def dashboard_card_count(title)
    case title
    when "Students" then Student.count
    when "Teachers" then Teacher.count
    when "Guardians" then Guardian.count
    when "School Years" then SchoolYear.count
    when "Academics" then Degree.count + FieldOfStudy.count + AcademicClass.count + Enrollment.count + EnrollmentPeriod.count
    when "Locations" then Country.count + Region.count + Province.count + City.count + Barangay.count + Citizenship.count
    else
      0
    end
  end
end
