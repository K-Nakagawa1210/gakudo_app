require 'caxlsx'
require 'holidays'

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

  # === Excel出力 ===
  def export_xlsx
    month = params[:month] ? Date.parse(params[:month]) : Date.current.beginning_of_month
    dates = (month..month.end_of_month).to_a
    students = Student.where(user_id: current_user.id).order(:grade_id, :student_name)
    attendances = Attendance.where(date: dates).includes(:student)
    attendance_by_date = attendances.group_by(&:date)
    weekday_jp = %w(日 月 火 水 木 金 土)

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "出欠一覧") do |sheet|
      styles = workbook.styles

      # --- スタイル定義 ---
      header_style = styles.add_style(b: true, alignment: { horizontal: :center, vertical: :center },
                                      border: { style: :thin, color: 'FF000000' })
      center_style = styles.add_style(alignment: { horizontal: :center, vertical: :center },
                                      border: { style: :thin, color: 'FF000000' })
      green_style = styles.add_style(bg_color: "C6EFCE", fg_color: "006100",
                                     alignment: { horizontal: :center, vertical: :center },
                                     border: { style: :thin, color: 'FF000000' })
      red_style = styles.add_style(bg_color: "FFC7CE", fg_color: "9C0006",
                                   alignment: { horizontal: :center, vertical: :center },
                                   border: { style: :thin, color: 'FF000000' })
      gray_style = styles.add_style(bg_color: "D9D9D9",
                                    alignment: { horizontal: :center, vertical: :center },
                                    border: { style: :thin, color: 'FF000000' })
      name_style = styles.add_style(alignment: { horizontal: :center, vertical: :center },
                                    border: { style: :thin, color: 'FF000000' })

      # --- ヘッダー ---
      header = ["児童名", "項目"] + dates.map { |d| "#{d.strftime("%-m/%-d")}(#{weekday_jp[d.wday]})" }
      sheet.add_row header, style: header_style

      start_row = 2

      # --- データ行 ---
      students.each do |student|
        attendance_row = [student.student_name, "出欠"]
        arrival_row    = ["", "登園"]
        leave_row      = ["", "帰宅"]

        style_row_attendance = [name_style, center_style]
        style_row_arrival    = [name_style, center_style]
        style_row_leave      = [name_style, center_style]

        dates.each do |day|
          record = attendance_by_date[day]&.find { |a| a.student_id == student.id }
          status = record&.status
          attendance_mark = record ? (status == "present" ? "〇" : "×") : "－"
          arrival_time = record&.arrival_time&.strftime("%H:%M") || "－"
          leave_time   = record&.leave_time&.strftime("%H:%M") || "－"

          # 曜日・祝日判定
          is_holiday = Holidays.on(day, :jp).any?
          cell_style = if day.sunday? || is_holiday
                         gray_style
                       elsif attendance_mark == "〇"
                         green_style
                       elsif attendance_mark == "×"
                         red_style
                       else
                         center_style
                       end

          attendance_row << attendance_mark
          arrival_row    << arrival_time
          leave_row      << leave_time

          style_row_attendance << cell_style
          style_row_arrival    << (day.sunday? || is_holiday ? gray_style : center_style)
          style_row_leave      << (day.sunday? || is_holiday ? gray_style : center_style)
        end

        sheet.add_row attendance_row, style: style_row_attendance
        sheet.add_row arrival_row,    style: style_row_arrival
        sheet.add_row leave_row,      style: style_row_leave

        # 児童名を3行結合
        sheet.merge_cells("A#{start_row}:A#{start_row + 2}")
        start_row += 3
      end

      # --- ヘッダー色（土日祝） ---
      sheet.rows[0].cells.each_with_index do |cell, i|
        next if i < 2
        date = dates[i - 2]
        if date.saturday?
          cell.style = styles.add_style(fg_color: "0000FF", b: true, alignment: { horizontal: :center })
        elsif date.sunday? || Holidays.on(date, :jp).any?
          cell.style = styles.add_style(fg_color: "FF0000", b: true, alignment: { horizontal: :center })
        end
      end

      # --- 列幅自動調整 ---
      column_widths = []

      # 児童名列
      max_name_length = students.map { |s| s.student_name.length }.max || 10
      column_widths << [max_name_length + 2, 20].max

      # 項目列
      column_widths << 10

      # 日付列
      dates.each do |day|
        max_len = 0
        students.each do |student|
          record = attendance_by_date[day]&.find { |a| a.student_id == student.id }
          attendance_mark = record ? (record.status == "present" ? "〇" : "×") : "－"
          arrival = record&.arrival_time&.strftime("%H:%M") || "－"
          leave   = record&.leave_time&.strftime("%H:%M") || "－"
          max_len = [max_len, attendance_mark.length, arrival.length, leave.length].max
        end
        column_widths << [max_len + 4, 10].max
      end

      sheet.column_widths(*column_widths)

      # 行高さ統一
      sheet.rows.each { |r| r.height = 20 }
    end

    send_data package.to_stream.read,
              filename: "出欠一覧_#{month.strftime('%Y年%m月')}.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  private

  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  def attendance_params
    params.require(:attendance).permit(:status, :arrival_time, :leave_time)
  end
end
