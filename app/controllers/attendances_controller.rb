class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:edit, :update]

 def index
  # 表示する月を決定（パラメータがなければ当月）
  @month = params[:month] ? Date.parse(params[:month]) : Date.current.beginning_of_month

  # 月の全日付を配列で取得
  @dates = (@month..@month.end_of_month).to_a

  # 日本語曜日の配列を作り、日付と曜日を結合した文字列を作る
  weekday_jp = %w(日 月 火 水 木 金 土)
  @dates_with_weekday = @dates.map { |d| "#{d.strftime('%-m/%-d')}（#{weekday_jp[d.wday]}）" }

  # 現在のユーザーの児童のみ取得
  @students = Student.where(user_id: current_user.id).order(:grade_id, :student_name)

  # 該当月の出席データを取得
  attendances = Attendance.joins(:student)
                          .where(students: { user_id: current_user.id }, date: @dates)
                          .order(:date)

  # 日付ごとにハッシュ化
  @attendances = attendances.group_by(&:date)

  # モーダル用に新しい Attendance インスタンスを作成
  @attendance = Attendance.new

  # 今日の日付＋曜日表示用
  today = Date.current
  @today_with_weekday = "#{today.strftime('%Y-%m-%d')}（#{weekday_jp[today.wday]}）"
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
