class StudentNumberSequence < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :prefix, presence: true

  def self.generate_next_number!
    sequence = begin
      find_or_create_by!(key: "default") do |record|
        record.prefix = "STU"
        record.last_value = 0
      end
    rescue ActiveRecord::RecordNotUnique
      find_by!(key: "default")
    end

    sequence.with_lock do
      sequence.last_value += 1
      sequence.save!
      "#{sequence.prefix}-#{Time.current.year}-#{sequence.last_value.to_s.rjust(6, '0')}"
    end
  end
end
