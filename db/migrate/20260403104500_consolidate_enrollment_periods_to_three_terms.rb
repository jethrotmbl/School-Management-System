class ConsolidateEnrollmentPeriodsToThreeTerms < ActiveRecord::Migration[5.2]
  class MigrationSchoolYear < ActiveRecord::Base
    self.table_name = "school_years"
  end

  class MigrationEnrollmentPeriod < ActiveRecord::Base
    self.table_name = "enrollment_periods"
  end

  class MigrationAcademicClass < ActiveRecord::Base
    self.table_name = "academic_classes"
  end

  class MigrationEnrollment < ActiveRecord::Base
    self.table_name = "enrollments"
  end

  TERM_NAMES = ["1st Semester", "2nd Semester", "Summer Term"].freeze

  def up
    MigrationSchoolYear.find_each do |school_year|
      periods = MigrationEnrollmentPeriod.where(school_year_id: school_year.id).order(:starts_on, :id).to_a
      next if periods.empty?

      term_ranges = build_term_ranges(school_year, periods)

      keepers = periods.first(3)

      while keepers.length < 3
        index = keepers.length
        keepers << MigrationEnrollmentPeriod.create!(
          school_year_id: school_year.id,
          name: "tmp-term-#{index + 1}-#{school_year.id}",
          starts_on: term_ranges[index][:starts_on],
          ends_on: term_ranges[index][:ends_on],
          status: "planning"
        )
      end

      keepers.each_with_index do |period, index|
        period.update_columns(
          name: "tmp-term-#{index + 1}-#{period.id}",
          starts_on: period.starts_on || term_ranges[index][:starts_on],
          ends_on: period.ends_on || term_ranges[index][:ends_on],
          status: normalize_status(period.status),
          updated_at: Time.current
        )
      end

      extras = MigrationEnrollmentPeriod.where(school_year_id: school_year.id).where.not(id: keepers.map(&:id)).order(:starts_on, :id).to_a

      extras.each do |extra|
        target = keepers.min_by { |keeper| date_distance(keeper.starts_on, extra.starts_on) }

        MigrationAcademicClass.where(enrollment_period_id: extra.id).update_all(enrollment_period_id: target.id, updated_at: Time.current)
        MigrationEnrollment.where(enrollment_period_id: extra.id).update_all(enrollment_period_id: target.id, updated_at: Time.current)

        extra.destroy!
      end

      keepers.each_with_index do |period, index|
        period.update_columns(
          name: TERM_NAMES[index],
          starts_on: period.starts_on || term_ranges[index][:starts_on],
          ends_on: period.ends_on || term_ranges[index][:ends_on],
          status: normalize_status(period.status),
          updated_at: Time.current
        )
      end

      active_terms = keepers.select { |period| period.status == "active" }.sort_by { |period| [period.starts_on || Date.current, period.id] }
      active_terms.drop(1).each do |period|
        period.update_columns(status: "completed", updated_at: Time.current)
      end
    end
  end

  def down
    # This consolidation is intentionally irreversible.
  end

  private

  def normalize_status(status)
    case status
    when "upcoming" then "planning"
    when "open" then "active"
    when "closed" then "completed"
    when "planning", "active", "completed" then status
    else "planning"
    end
  end

  def build_term_ranges(school_year, periods)
    starts_on = school_year.starts_on || periods.map(&:starts_on).compact.min || Date.current
    ends_on = school_year.ends_on || periods.map(&:ends_on).compact.max || starts_on

    total_days = [(ends_on - starts_on).to_i, 0].max
    first_end = [starts_on + (total_days / 3), ends_on].min
    second_start = [first_end + 1, ends_on].min
    second_end = [starts_on + ((total_days * 2) / 3), ends_on].min
    second_end = second_start if second_end < second_start
    third_start = [second_end + 1, ends_on].min

    [
      { starts_on: starts_on, ends_on: first_end },
      { starts_on: second_start, ends_on: second_end },
      { starts_on: third_start, ends_on: ends_on }
    ]
  end

  def date_distance(first_date, second_date)
    return 0 if first_date.blank? && second_date.blank?
    return 10_000 if first_date.blank? || second_date.blank?

    (first_date - second_date).abs.to_i
  end
end
