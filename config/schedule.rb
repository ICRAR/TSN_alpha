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

set :environment, 'development'

every :hour do
  rake "stats:update_boinc"
  rake "stats:update_general"
  rake "stats:update_alliances"
  rake "stats:update_trophy"
  rake "nereus:update_nereus"
end
