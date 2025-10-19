namespace :attendance do
  desc "19時に未出席児童を欠席にする"
  task mark_absent: :environment do
    today = Date.current
    Student.find_each do |student|
      attendance = Attendance.find_by(student_id: student.id, date: today)
      unless attendance
        Attendance.create!(
          student_id: student.id,
          date: today,
          status: :absent
        )
      end
    end
  end
end
