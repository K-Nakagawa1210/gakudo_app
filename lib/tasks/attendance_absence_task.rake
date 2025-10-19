namespace :attendance do
  desc "19:00になったら登園していない児童を欠席登録する"
  task mark_absent: :environment do
    today = Date.current
    weekday_jp = %w(日 月 火 水 木 金 土)
    students = Student.all

    students.each do |student|
      # 今日の出席記録がない児童だけを対象
      unless Attendance.exists?(student_id: student.id, date: today)
        Attendance.create!(
          student_id: student.id,
          date: today,
          status: "absent"
        )
      end
    end

    puts "#{today.strftime('%Y-%m-%d')}（#{weekday_jp[today.wday]}）の欠席登録完了"
  end
end
