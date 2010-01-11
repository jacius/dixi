load 'deploy' if respond_to?(:namespace) # cap2 differentiator

default_run_options[:pty] = true
ssh_options[:forward_agent] = true


#############
# CAPCONFIG #
#############

require 'yaml'
begin
  capconfig = YAML.load_file("capconfig.yaml")
rescue
  puts <<EOS 
ERROR: Oops, capconfig.yaml seems to be missing or invalid!
Use `rake capconfig.yaml` to create it, then edit it to fill in your
deployment details.
EOS
  exit 1
end

capconfig = {
  :application => 'dixi',
  :deploy_via => :remote_cache,
  :branch => 'master',
}.merge(capconfig)


set :user, capconfig[:user]
set :domain, capconfig[:domain]
set :application, capconfig[:application]

set :repository,  capconfig[:repository]
set :local_repository, capconfig[:local_repository]
set :deploy_to, capconfig[:deploy_to]
set :deploy_via, capconfig[:deploy_via]
set :scm, 'git'
set :branch, capconfig[:branch]
set :scm_verbose, true
set :use_sudo, false

server domain, :app, :web


namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
end


after :deploy do
  run "ln -s #{shared_path}/contents #{release_path}/contents"
  run "ln -s #{shared_path}/vendor #{release_path}/vendor"
  run "cd #{release_path} && rake index"
end
