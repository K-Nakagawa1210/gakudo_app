class CreateGrades < ActiveRecord::Migration[7.0]
  def change
    create_table :grades do |t|
      t.string :name, null: false             # seeds.rb の grade_name を格納
      t.integer :level,     null: false       # 学年のレベル
      t.integer :year                         # 年度

      t.timestamps
    end
  end
end
