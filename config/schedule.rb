every 1.day, at: '19:00' do
  rake "attendance:mark_absent"
end

set :environment, "production"
set :output, "log/cron_log.log"

# 毎年4月1日 0:00 に実行
every 1.year, at: 'April 1st 00:00' do
  runner "Student.promote_all_grades"
end
