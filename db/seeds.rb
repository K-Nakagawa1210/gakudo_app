grades = [
  { grade_name: "1年生", level: 1, year: 2025 },
  { grade_name: "2年生", level: 2, year: 2025 },
  { grade_name: "3年生", level: 3, year: 2025 },
  { grade_name: "4年生", level: 4, year: 2025 },
  { grade_name: "5年生", level: 5, year: 2025 },
  { grade_name: "6年生", level: 6, year: 2025 }
]

grades.each do |grade|
  # DBのカラム名に正しくマッピング
  Grade.create!(
    name: grade[:grade_name],  # ← ここを必ず name にする
    level: grade[:level],
    year: grade[:year]
  )
end

puts "Grades seeded successfully!"
