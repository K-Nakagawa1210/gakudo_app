class CreateSchools < ActiveRecord::Migration[7.1]
  def change
    create_table :schools do |t|
      t.string :school_name,     null: false
      t.references :user,        null: false, foreign_key: true
      t.timestamps
    end
  end
end
