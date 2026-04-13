class AddRelationshipToStudentGuardians < ActiveRecord::Migration[5.2]
  def up
    add_column :student_guardians, :relationship_to_student, :string

    execute <<~SQL
      UPDATE student_guardians
      INNER JOIN guardians ON guardians.id = student_guardians.guardian_id
      SET student_guardians.relationship_to_student = guardians.relationship_to_student
      WHERE guardians.relationship_to_student IS NOT NULL
        AND guardians.relationship_to_student <> ''
    SQL
  end

  def down
    remove_column :student_guardians, :relationship_to_student
  end
end
