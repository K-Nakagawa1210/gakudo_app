class CreateGrades < ActiveRecord::Migration[7.1]
  def change
    create_table :grades do |t|
      t.string :name,   null: false       # 表示用（例："1年生"）
      t.integer :level, null: false       # 論理用（例：1, 2, 3, ...）
      t.timestamps
    end
  end
end
