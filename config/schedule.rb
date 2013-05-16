# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# update crontab with whenever -w run from root_dir
# whenever --set 'environment=production' -w
# rvmsudo whenever --update-crontab tsn_alpha

job_type :srake,    "cd :path && RAILS_ENV=:environment spring rake :task --silent :output"
set :environment, 'production'

every '10 * * * *' do
  rake "boinc:update_boinc"
end
every '20 * * * *' do
  rake "nereus:update_all"
end
every '30 * * * *' do
  rake "stats:update_general"
end
every '40 * * * *' do
  rake "stats:update_alliances"
end
every '50 * * * *' do
  rake "stats:update_trophy"
end
