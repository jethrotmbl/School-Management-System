class NormalizeEnrollmentPeriodStatusesAndBackfillTerms < ActiveRecord::Migration[5.2]
  class MigrationSchoolYear < ActiveRecord::Base
    self.table_name = "school_years"
  end

  class MigrationEnrollmentPeriod < ActiveRecord::Base
    self.table_name = "enrollment_periods"
  end

  TERM_NAMES = ["1st Semester", "2nd Semester", "Summer Term"].freeze

  def up
    execute "UPDATE enrollment_periods SET status = 'planning' WHERE status = 'upcoming'"
    execute "UPDATE enrollment_periods SET status = 'active' WHERE status = 'open'"
    execute "UPDATE enrollment_periods SET status = 'completed' WHERE status = 'closed'"

    change_column_default :enrollment_periods, :status, from: "upcoming", to: "planning"

    MigrationSchoolYear.find_each do |school_year|
      active_periods = MigrationEnrollmentPeriod.where(school_year_id: school_year.id, status: "active").order(:starts_on, :id).to_a
      active_periods.drop(1).each do |period|
        period.update_columns(status: "completed", updated_at: Time.current)
      end

      next if school_year.starts_on.blank? || school_year.ends_on.blank?

      term_ranges = build_term_ranges(school_year.starts_on, school_year.ends_on)

      TERM_NAMES.each_with_index do |term_name, index|
        MigrationEnrollmentPeriod.find_or_create_by!(school_year_id: school_year.id, name: term_name) do |period|
          period.starts_on = term_ranges[index][:starts_on]
          period.ends_on = term_ranges[index][:ends_on]
          period.status = "planning"
        end
      end
    end
  end

  def down
    execute "UPDATE enrollment_periods SET status = 'upcoming' WHERE status = 'planning'"
    execute "UPDATE enrollment_periods SET status = 'open' WHERE status = 'active'"
    execute "UPDATE enrollment_periods SET status = 'closed' WHERE status = 'completed'"

    change_column_default :enrollment_periods, :status, from: "planning", to: "upcoming"
  end

  private

  def build_term_ranges(starts_on, ends_on)
    total_days = [(ends_on - starts_on).to_i, 0].max
    first_end = starts_on + (total_days / 3)
    second_end = starts_on + ((total_days * 2) / 3)

    first_end = [first_end, ends_on].min
    second_start = [first_end + 1, ends_on].min
    second_end = [second_end, ends_on].min
    second_end = second_start if second_end < second_start
    third_start = [second_end + 1, ends_on].min

    [
      { starts_on: starts_on, ends_on: first_end },
      { starts_on: second_start, ends_on: second_end },
      { starts_on: third_start, ends_on: ends_on }
    ]
  end
end
