class SchoolsController < ApplicationController
  before_action :set_school, only: [:edit, :update, :destroy]
  def index
    @schools = current_user.schools.order(:school_name)
  end

  def attendance_index
    @schools = current_user.schools.order(:school_name)
  end

  def show
    @school = School.find(params[:id])
    @students = @school.students.order(:grade, :school_name)
  end

  def new
    @school = School.new
  end

  def create
    @school = current_user.schools.build(school_params)
    if @school.save
      redirect_to schools_path, notice: "#{@school.school_name}を追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @school.update(school_params)
      redirect_to school_path, notice: "#{@school.school_name}を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @school.destroy
    redirect_to schools_path, notice: "#{@school.school_name}を削除しました"
  end

  private

  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(:school_name)
  end
end
