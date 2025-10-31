class SeedGradeData < ActiveRecord::Migration[7.1]
  def up
    puts "Invoking db:seed..."
    Rake::Task['db:seed'].reenable
    Rake::Task['db:seed'].invoke
    puts "db:seed finished."
  end

  def down
    # データを削除したい場合はここに記述
  end
end
