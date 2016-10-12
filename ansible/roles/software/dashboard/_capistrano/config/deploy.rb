set :application, 'dashboard'
set :scm, :git
set :git_strategy, Capistrano::Git::SubmoduleStrategy
set :repo_url, 'git@github.com:GSA/project-open-data-dashboard.git'

# Branch options
# Prompts for the branch name (defaults to current branch)
#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Sets branch to current one
#set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Hardcodes branch to always be master
# This could be overridden in a stage config file
set :branch, :master
set :deploy_to, "/var/www/labs/#{fetch(:application)}"
set :keep_releases, 3

set :log_level, :info

set :linked_files, %w{.env .htaccess}
set :linked_dirs, %w{uploads downloads archive}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :service, :nginx, :reload
    end
  end
end

# The above restart task is not run by default
# Uncomment the following line to run it on deploys if needed
# after 'deploy:publishing', 'deploy:restart'
