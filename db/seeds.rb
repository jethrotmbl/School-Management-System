puts "Starting database seeding..."

require "fileutils"

def truncate_tables!(*tables)
  connection = ActiveRecord::Base.connection
  connection.execute("SET FOREIGN_KEY_CHECKS = 0")
  tables.each do |table_name|
    connection.execute("TRUNCATE TABLE #{table_name}")
  end
  connection.execute("SET FOREIGN_KEY_CHECKS = 1")
end

truncate_tables!(
  "card_actions",
  "homepage_cards",
  "enrollments",
  "academic_classes",
  "enrollment_periods",
  "student_guardians",
  "students",
  "guardians",
  "teachers",
  "student_number_sequences",
  "field_of_studies",
  "degrees",
  "school_years",
  "departments",
  "citizenships",
  "barangays",
  "cities",
  "provinces",
  "regions",
  "countries"
)

def ensure_profile_image_placeholders!(folder_name:, target_count:, code_prefix:, fallback_prefix:)
  root_path = Rails.root.join("db", "seeds", "images", folder_name)
  return unless Dir.exist?(root_path)

  extensions = %w[png jpg jpeg webp gif]
  source_files = Dir.children(root_path)
                    .select { |file_name| file_name.match?(/\A#{Regexp.escape(fallback_prefix)}\d+\.(png|jpe?g|webp|gif)\z/i) }
                    .sort_by { |file_name| file_name[/\d+/].to_i }

  if source_files.empty?
    source_files = Dir.children(root_path)
                      .select { |file_name| file_name.match?(/\A#{Regexp.escape(code_prefix)}\d+\.(png|jpe?g|webp|gif)\z/i) }
                      .sort_by { |file_name| file_name[/\d+/].to_i }
  end

  return if source_files.empty?

  (1..target_count).each do |record_id|
    existing = extensions.any? do |extension|
      File.exist?(root_path.join("#{code_prefix}#{record_id}.#{extension}")) ||
        File.exist?(root_path.join("#{code_prefix}#{record_id.to_s.rjust(3, '0')}.#{extension}"))
    end
    next if existing

    source_file_name = source_files[(record_id - 1) % source_files.length]
    source_file_path = root_path.join(source_file_name)
    target_extension = File.extname(source_file_name)
    target_file_path = root_path.join("#{code_prefix}#{record_id}#{target_extension}")
    FileUtils.cp(source_file_path, target_file_path)
  end
end

def seeded_profile_image_path(folder_name:, code_prefix:, image_index:)
  root_path = Rails.root.join("db", "seeds", "images", folder_name)
  return unless Dir.exist?(root_path)

  extensions = %w[png jpg jpeg webp gif]

  extensions.each do |extension|
    file_path = root_path.join("#{code_prefix}#{image_index}.#{extension}")
    return file_path if File.exist?(file_path)

    padded_file_path = root_path.join("#{code_prefix}#{image_index.to_s.rjust(3, '0')}.#{extension}")
    return padded_file_path if File.exist?(padded_file_path)
  end

  nil
end

def attach_seed_profile_image!(record:, folder_name:, code_prefix:, image_index:)
  return if record.blank? || !record.respond_to?(:profile_photo)

  image_path = seeded_profile_image_path(
    folder_name: folder_name,
    code_prefix: code_prefix,
    image_index: image_index
  )
  return if image_path.blank?

  File.open(image_path, "rb") do |file|
    record.profile_photo.attach(
      io: file,
      filename: File.basename(image_path)
    )
  end
end

ensure_profile_image_placeholders!(folder_name: "students", target_count: 100, code_prefix: "S", fallback_prefix: "student")
ensure_profile_image_placeholders!(folder_name: "teachers", target_count: 50, code_prefix: "T", fallback_prefix: "teacher")
ensure_profile_image_placeholders!(folder_name: "guardians", target_count: 100, code_prefix: "G", fallback_prefix: "guardian")

seed_files = [
  "locations/base.rb",
  "citizenships.rb",
  "departments.rb",
  "school_years.rb",
  "teachers/teachers.rb",
  "guardians/guardians.rb",
  "academics/base.rb",
  "students/students.rb",
  "homepage_cards.rb"
]

seed_files.each do |file_name|
  file = Rails.root.join("db", "seeds", file_name).to_s
  puts "Processing #{file_name}"
  require file
end

puts "Seeding complete."
