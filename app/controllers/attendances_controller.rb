class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:edit, :update]

  def index
    @month = params[:month] ? Date.parse(params[:month]) : Date.current.beginning_of_month
    @students = Student.order(:id)
    @dates = (@month.beginning_of_month..@month.end_of_month).to_a

    @attendances = Attendance
                     .includes(:student)
                     .where(date: @month.beginning_of_month..@month.end_of_month)
                     .order(:date, "students.id")
                     .group_by(&:date)
  end

  def edit
  end

  def update
    if @attendance.update(attendance_params)
      redirect_to attendances_path(month: @attendance.date.beginning_of_month), notice: "出欠を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # === CSV出力 ===
  def export_csv
    month = params[:month] ? Date.parse(params[:month]) : Date.current.beginning_of_month
    csv_data = Attendance.to_csv(month)
    send_data csv_data, filename: "attendances_#{month.strftime('%Y%m')}.csv", type: :csv
  end

  private

  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  def attendance_params
    params.require(:attendance).permit(:status, :arrival_time, :leave_time)
  end
end
