set :stage, :dev

set :branch, ENV['branch'] || :master
set :deploy_to, "/var/www/html/#{fetch(:application)}"
set :tmp_dir, "/var/www/dashboard/tmp"

# Simple Role Syntax
# ==================
#role :app, %w{deploy@example.com}
#role :web, %w{deploy@example.com}
#role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
server '52.2.208.242', user: 'deploy', roles: %w{web app db}

#set :copy_exclude, [".git", ".DS_Store", ".gitignore", ".gitmodules"]

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }

#fetch(:default_env).merge!(wp_env: :qa)

