class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:edit, :update, :destroy]
  before_action :set_school, only: [:attend]

  # 児童管理ページ（設定画面)
  def index
    if params[:school_id]
      @school = School.find(params[:school_id])
      @students = current_user.students
                  .where(school_id: @school.id)   # ← ここで絞り込み
                  .includes(:school, :grade)
                  .order(:grade_id, :student_name)
    else
      @school = nil
      @students = current_user.students
                  .includes(:school, :grade)
                  .order(:school_id, :grade_id, :student_name)
    end
    @today = Time.current
  end

  def attend
    @school = School.find(params[:school_id])
    @students = @school.students.order(:grade_id, :student_name)
    @today = Date.current
  end

  def attend_create
    @school = School.find(params[:school_id])
    selected_ids = params[:student_ids] || []
    today = Date.current

    if params[:action_type] == "attend"
      selected_ids.each do |id|
        Attendance.find_or_create_by(student_id: id, date: today) do |a|
          a.status = "present"
          a.arrival_time = Time.current
        end
      end
      message = "登園を登録しました"
    elsif params[:action_type] == "leave"
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

  def manage
    @students = current_user.students.includes(:school, :grade).order(:school_id, :grade_id, :student_name)
  end

  def new
    @student = current_user.students.build
    @schools = current_user.schools.order(:school_name)
    @grades = Grade.order(:level)
  end

  def create
    @student = current_user.students.build(student_params)
    if @student.save
      redirect_to manage_students_path, notice: "児童を登録しました"
    else
      @schools = current_user.schools.order(:school_name)
      @grades = Grade.order(:level)
      render :new
    end
  end

  def edit
    @student = current_user.students.find(params[:id])
    @schools = current_user.schools.order(:school_name)
    @grades = Grade.order(:level)
  end

  def update
    @student = current_user.students.find(params[:id])
    if @student.update(student_params)
      redirect_to manage_students_path, notice: "児童情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student = current_user.students.find(params[:id])
    @student.destroy
    redirect_to manage_students_path, notice: "児童を削除しました"
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
