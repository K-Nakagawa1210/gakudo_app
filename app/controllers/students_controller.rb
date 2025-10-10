class StudentsController < ApplicationController
  def index
    @school = School.find(params[:school_id])
    @students = @school.students.order(:grade, :name)
  end

  def attend
    params[:student_ids].each do |id|
      student = Student.find(id)
      Attendance.create!(
        student: student,
        date: Date.today,
        status: "present",
        time: Time.current
      )
    end
    redirect_to school_students_path(params[:school_id]), notice: "出席を登録しました"
  end
end
