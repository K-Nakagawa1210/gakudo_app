# db/migrate/20251031135732_seed_grade_data.rb

class SeedGradeData < ActiveRecord::Migration[7.1]
  def up
    # db:seeds.rb の代わりに、ここで直接データを定義・投入する
    grades = [
      { grade_name: "1年生", level: 1, year: 2025 },
      { grade_name: "2年生", level: 2, year: 2025 },
      { grade_name: "3年生", level: 3, year: 2025 },
      { grade_name: "4年生", level: 4, year: 2025 },
      { grade_name: "5年生", level: 5, year: 2025 },
      { grade_name: "6年生", level: 6, year: 2025 }
    ]

    # Grade モデルに直接アクセスしてデータを作成
    grades.each do |grade|
      # find_or_create_by! は、データが存在しなければ作成、存在すれば何もしない
      Grade.find_or_create_by!(
        name: grade[:grade_name], # DBのカラム名: name を使用
        level: grade[:level],
        year: grade[:year]
      )
    end
    puts "Grades data successfully created via migration."
  end

  def down
    # マイグレーションをロールバックする場合、投入したデータを削除
    # データを削除する方が安全なため、このdownメソッドを定義します。
    Grade.where(level: 1..6).destroy_all 
    puts "Grades data successfully destroyed via migration."
  end
end