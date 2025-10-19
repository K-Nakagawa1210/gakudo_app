class CreateStudents < ActiveRecord::Migration[7.1]
  def change
    create_table :students do |t|
      t.string :student_name,    null: false
      t.references :school,      null: false, foreign_key: true
      t.references :grade,       null: false, foreign_key: true
      t.timestamps
    end
  end
end
