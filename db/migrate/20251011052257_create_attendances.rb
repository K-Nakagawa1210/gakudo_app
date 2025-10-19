class CreateAttendances < ActiveRecord::Migration[7.0]
  def change
    create_table :attendances do |t|
      t.references :student, null: false, foreign_key: true  # 児童との関連
      t.date :date, null: false                              # 日付
      t.integer :status, null: false, default: 0              # 出欠（0: 出席, 1: 欠席）
      t.time :arrival_time                                   # 登園時間
      t.time :leave_time                                     # 帰宅時間

      t.timestamps
    end

    # 同じ児童の同じ日の重複登録を防ぐ
    add_index :attendances, [:student_id, :date], unique: true
  end
end
