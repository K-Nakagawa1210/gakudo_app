class StudentsController < ApplicationController
  before_action :set_student, only: [:edit, :update, :destroy]
  before_action :set_school, only: [:attend, :leave, :index]

  # 小学校別児童一覧（出席登録画面）
  def index
    @school = School.find(params[:school_id])
    @students = @school.students.order(:grade_id, :student_name)
    @today = Time.current
  end

  def attend
    @school = School.find(params[:school_id])
    selected_ids = params[:student_ids] || []
    today = Date.current

    if params[:action_type] == "attend"
      # 登園処理
      selected_ids.each do |id|
        Attendance.find_or_create_by(student_id: id, date: today) do |a|
          a.status = "present"
          a.arrival_time = Time.current
        end
      end
      message = "登園を登録しました"

    elsif params[:action_type] == "leave"
      # 帰宅処理
      selected_ids.each do |id|
        attendance = Attendance.find_by(student_id: id, date: today)
        attendance&.update(leave_time: Time.current)
      end
      message = "帰宅を登録しました"

    else
      message = "処理が選択されていません"
    end

    redirect_to attendance_index_schools_path, notice: message
  end


  def leave
  end


  # 通常の生徒管理部分
  def new
    @student = Student.new
    @schools = School.all
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to students_path, notice: "#{@student.student_name}を追加しました"
    else
      @schools = School.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @schools = School.all
  end

  def update
    if @student.update(student_params)
      redirect_to students_path, notice: "#{@student.student_name}を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: "#{@student.student_name}を削除しました"
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:student_name, :school_id, :grade_id)
  end

  def set_school
    @school = School.find(params[:school_id])
  end
end
