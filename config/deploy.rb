# config valid only for current version of Capistrano
lock "3.9.1"

set :application, "appcacmu"
ask :git_http_password
set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }
set :repo_url, "https://github.com/githubpopckorn/appcacmu.git"
set :deploy_to, '/home/deploy/appcacmu'
require 'whenever/capistrano'

# append :linked_files, "config/database.yml", "config/secrets.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", "public/system", "public/uploads"


# Whenever
set :whenever_command, 'bundle exec whenever'

# Configure 'whenever'
vars = lambda do
  "'environment=#{fetch :whenever_environment}" \
  "&rbenv_root=#{fetch :rbenv_custom_path}" \
  "&rbenv_version=#{fetch :rbenv_ruby}'"
end
set :whenever_variables, vars


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
