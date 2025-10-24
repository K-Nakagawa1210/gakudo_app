class Student < ApplicationRecord
  belongs_to :user
  belongs_to :school
  belongs_to :grade
  has_many :attendances, dependent: :destroy

  alias_attribute :name, :student_name

   # 学年を1つ上げるクラスメソッド
  def self.promote_all_grades
    all.find_each do |student|
      # 6年生は卒業
      if student.grade < 6
        student.update(grade: student.grade + 1)
      else
        # 6年生を削除
        student.update(graduated: true) if student.respond_to?(:graduated)
      end
    end
  end
end
