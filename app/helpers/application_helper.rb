module ApplicationHelper
  require "base64"

  def kendo_icon(name, classes: nil, label: nil)
    resolved_name = normalize_kendo_icon_name(name)

    attributes = {
      class: ["k-icon", "k-i-#{resolved_name}", classes].compact.join(" "),
      role: (label.present? ? "img" : "presentation"),
      "aria-hidden": label.present? ? nil : true,
      "aria-label": label
    }.compact

    content_tag(:span, nil, **attributes)
  end

  def normalize_kendo_icon_name(name)
    icon_name = name.to_s

    return "clipboard" if icon_name == "user-group"

    icon_name
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
        icon: "clipboard",
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
          { key: "school_years-new", label: "Open School Year", path: school_years_path }
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

  def render_app_breadcrumbs
    crumbs = app_breadcrumbs
    return if crumbs.blank?

    content_tag(:nav, class: "app-breadcrumb-wrap", aria: { label: "Breadcrumb" }) do
      content_tag(:ol, class: "breadcrumb app-breadcrumb mb-0") do
        safe_join(
          crumbs.each_with_index.map do |crumb, index|
            is_last = index == crumbs.length - 1
            item_classes = ["breadcrumb-item"]
            item_classes << "active" if is_last || crumb[:path].blank?

            content_tag(:li, class: item_classes.join(" "), "aria-current": (is_last ? "page" : nil)) do
              if crumb[:path].present? && !is_last
                link_to(crumb[:label], crumb[:path])
              else
                crumb[:label]
              end
            end
          end
        )
      end
    end
  end

  def app_breadcrumbs
    return [] if controller_name == "home" && action_name == "index"

    crumbs = [{ label: "Home", path: root_path }]
    collection_path = breadcrumb_collection_path

    if collection_path.present?
      crumbs << { label: breadcrumb_collection_label, path: collection_path }
    end

    case action_name
    when "show"
      append_record_crumb(crumbs)
    when "new", "create"
      crumbs << { label: "New", path: nil }
    when "edit", "update"
      append_record_crumb(crumbs, link_to_record: true)
      crumbs << { label: "Edit", path: nil }
    when "search"
      crumbs << { label: "Search", path: nil }
    when "index"
      crumbs[-1] = { label: breadcrumb_collection_label, path: nil } if collection_path.present?
    else
      crumbs << { label: action_name.to_s.titleize, path: nil }
    end

    crumbs.uniq { |crumb| [crumb[:label], crumb[:path]] }
  end

  def append_record_crumb(crumbs, link_to_record: false)
    record = breadcrumb_record
    label = breadcrumb_record_label(record)
    return if label.blank?

    crumbs << {
      label: label,
      path: link_to_record ? breadcrumb_record_path(record) : nil
    }
  end

  def breadcrumb_collection_label
    {
      "academic_classes" => "Classes"
    }.fetch(controller_name, controller_name.to_s.titleize)
  end

  def breadcrumb_collection_path
    url_for(controller: controller_name, action: :index, only_path: true)
  rescue StandardError
    nil
  end

  def breadcrumb_record
    instance_variable_get("@#{controller_name.to_s.singularize}")
  end

  def breadcrumb_record_label(record)
    return if record.blank?

    [:breadcrumb_label, :display_name, :full_name, :name, :title].each do |method_name|
      next unless record.respond_to?(method_name)

      value = record.public_send(method_name)
      return value if value.present?
    end

    return record.employee_number if record.respond_to?(:employee_number) && record.employee_number.present?
    return record.student_number if record.respond_to?(:student_number) && record.student_number.present?
    return "##{record.id}" if record.respond_to?(:id)

    record.to_s
  end

  def breadcrumb_record_path(record)
    polymorphic_path(record)
  rescue StandardError
    nil
  end

  def profile_image_tag(record, category:, classes: "admin-profile-photo", size: 168)
    image_tag(
      profile_image_source(record, category: category),
      alt: "#{breadcrumb_record_label(record)} profile photo",
      class: classes,
      width: size,
      height: size,
      loading: "lazy"
    )
  end

  def profile_image_source(record, category:)
    seeded_data = seeded_profile_image_data(record, category: category)
    return seeded_data if seeded_data.present?

    generated_profile_avatar(record)
  end

  def seeded_profile_image_data(record, category:)
    return if record.blank? || record.respond_to?(:id) && record.id.blank?

    folder_name = category.to_s.pluralize
    root_path = Rails.root.join("db", "seeds", "images", folder_name)
    return unless Dir.exist?(root_path)

    record_id = record.id.to_i
    return if record_id <= 0

    preferred_prefix = seeded_profile_image_prefix(category)
    selected_file = seeded_profile_image_file_for_id(root_path, preferred_prefix, record_id)
    selected_file ||= seeded_profile_image_file_for_id(root_path, category.to_s.singularize, record_id)
    return unless selected_file

    extension = File.extname(selected_file.to_s).delete(".").downcase
    mime_type = case extension
                when "jpg", "jpeg"
                  "image/jpeg"
                when "gif"
                  "image/gif"
                when "webp"
                  "image/webp"
                else
                  "image/png"
                end

    encoded_file = Base64.strict_encode64(File.binread(selected_file))
    "data:#{mime_type};base64,#{encoded_file}"
  rescue StandardError
    nil
  end

  def seeded_profile_image_prefix(category)
    case category.to_s.singularize
    when "student"
      "S"
    when "teacher"
      "T"
    when "guardian"
      "G"
    else
      category.to_s.singularize
    end
  end

  def seeded_profile_image_file_for_id(root_path, prefix, id)
    extensions = %w[png jpg jpeg webp gif]
    candidate_bases = ["#{prefix}#{id}", "#{prefix}#{id.to_s.rjust(3, '0')}"]

    candidate_bases.each do |base_name|
      extensions.each do |extension|
        path = root_path.join("#{base_name}.#{extension}")
        return path if File.exist?(path)
      end
    end

    nil
  end

  def generated_profile_avatar(record)
    label = breadcrumb_record_label(record).to_s
    initials = label.split(/\s+/).map { |part| part[0] }.compact.first(2).join.upcase
    initials = "NA" if initials.blank?

    svg = <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="336" height="336" viewBox="0 0 336 336" role="img" aria-label="#{ERB::Util.html_escape(label)}">
        <defs>
          <linearGradient id="avatar-bg" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stop-color="#dbeafe"/>
            <stop offset="100%" stop-color="#bfdbfe"/>
          </linearGradient>
        </defs>
        <rect width="336" height="336" rx="24" fill="url(#avatar-bg)"/>
        <circle cx="168" cy="118" r="64" fill="#0f172a" fill-opacity="0.92"/>
        <path d="M58 286c0-58 48-96 110-96s110 38 110 96" fill="#0f172a" fill-opacity="0.86"/>
        <text x="168" y="308" text-anchor="middle" font-family="Segoe UI, Arial, sans-serif" font-size="44" font-weight="700" fill="#ffffff">#{ERB::Util.html_escape(initials)}</text>
      </svg>
    SVG

    "data:image/svg+xml,#{ERB::Util.url_encode(svg)}"
  end
end
