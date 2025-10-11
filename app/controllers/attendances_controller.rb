class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:edit, :update]

  def index
    @month = params[:month] ? Date.parse(params[:month]) : Date.current.beginning_of_month
    @dates = (@month..@month.end_of_month).to_a
    @students = Student.all
    @attendances = Attendance.where(date: @dates).group_by(&:date)
    @attendance = Attendance.new # モーダルで使う新しいインスタンス
  end

  def edit
    @attendance = Attendance.find(params[:id])
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    @attendance = Attendance.find(params[:id])
    if @attendance.update(attendance_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to attendances_path(month: @attendance.date.beginning_of_month), notice: "出欠を更新しました。" }
      end
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
