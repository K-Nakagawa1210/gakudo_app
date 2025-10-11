class StudentsController < ApplicationController
  before_action :set_student, only: [:edit, :update, :destroy]
  before_action :set_school, only: [:attend, :index_by_school]

  def index
    @students = Student.all.order(:school_id, :student_name)
  end

  def attend
    @students = @school.students.order(:grade_id, :student_name)
  end

  def attend_post
    student_ids = params[:student_ids] || []
    student_ids.each do |id|
      Attendance.create!(
        student_id: id,
        date: Date.today,
        status: "present",
        time: Time.current
      )
    end
    redirect_to attend_school_students_path(@school), notice: "出席を登録しました"
  end

  def new
    @student = Student.new
    @schools = School.all  # 学校選択用
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to students_path, notice: "#{@student.student_name}を追加しました。"
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
      redirect_to students_path, notice: "#{@student.student_name}を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: "#{@student.student_name}を削除しました。"
  end

  def index_by_school
    @students = Student.where(school_id: params[:school_id]).order(:grade_id, :student_name)
    @school = School.find(params[:school_id])
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
