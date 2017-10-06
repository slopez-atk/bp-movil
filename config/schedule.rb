# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
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
# set :rbenv_root, "/Users/santy/.rbenv/"
# env :MAIlTO, "root"
# env :PATH, "#{rbenv_root}/shims:#{rbenv_root}/bin:/bin:/usr/bin"
# env :RBENV_VERSION, "2.4.0"
# set :environment, :development

set :rbenv_root, '/home/deploy/.rbenv'
set :rbenv_version, '2.4.1'
env 'RBENV_ROOT', rbenv_root
env 'RBENV_VERSION', rbenv_version
set :environment, :production
env :PATH, "#{rbenv_root}/shims:#{rbenv_root}/bin:/bin:/usr/bin"
set :output, {:error => '/home/deploy/error.log', :standard => '/home/deploy/standar.log'}

every 1.day, :at => '5:00 am' do
  runner "Oracledb.guardar_creditos_pendientes"
end

every 2.minutes do
  runner "Oracledb.guardar_creditos_pendientes"
end