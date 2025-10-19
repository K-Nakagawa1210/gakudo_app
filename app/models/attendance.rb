class Attendance < ApplicationRecord
  belongs_to :student

  enum status: { present: 0, absent: 1 }  # 出欠
  validates :date, presence: true

  # CSV出力用
  def self.to_csv(month)
    require "csv"

    start_date = month.beginning_of_month
    end_date = month.end_of_month
    students = Student.all.order(:id)
    attendances = where(date: start_date..end_date).includes(:student)

    CSV.generate(headers: true, force_quotes: true) do |csv|
      header = ["日付"] + students.map(&:name)
      csv << header

      (start_date..end_date).each do |day|
        row = [day.strftime("%-m/%-d")]
        students.each do |student|
          record = attendances.find { |a| a.student_id == student.id && a.date == day }
          if record
            mark = record.present? ? "〇" : "×"
            times = []
            times << record.arrival_time.strftime("%H:%M") if record.arrival_time
            times << record.leave_time.strftime("%H:%M") if record.leave_time
            row << [mark, *times].join(" ")
          else
            row << ""
          end
        end
        csv << row
      end
    end
  end
end
