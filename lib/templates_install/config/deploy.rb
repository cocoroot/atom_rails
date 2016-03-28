# coding: utf-8
# config valid only for current version of Capistrano
lock '3.4.0'

REPO_URL = "#{ENV['GIT_REPOSITORY_URL']}".gsub('https://', "https://#{ENV['GIT_HTTPS_USERNAME']}:#{ENV['GIT_HTTPS_PASSWORD']}@")

# 環境変数名（キー）を設定
# 同一サーバにデプロイしても上書きされないよう、必ずアプリ毎に変える
#（管理画面用であれば SECRET_KEY_BASE_MNG にする等）
SECRET_KEY_BASE_KEY_NAME = 'SECRET_KEY_BASE'

#################### Settings ####################
set :application, ENV['PROJECT_NAME']
set :repo_url, REPO_URL
set :repo_url_, ENV['GIT_REPOSITORY_URL']
set :branch, 'release'
set :deploy_to, "/var/www/#{ENV['PROJECT_NAME']}"
set :scm, :git
set :format, :pretty
set :log_level, :debug
set :pty, true # default is false
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

set :default_env, {
  rbenv_root:        "~/.rbenv",
  path:              "~/.rbenv/shims:~/.rbenv/bin:$PATH",
  project_name:      ENV['PROJECT_NAME'],
  database_name:     ENV['DATABASE_NAME'],
  database_host:     ENV['DATABASE_HOST'],
  database_port:     ENV['DATABASE_PORT'],
  database_user:     ENV['DATABASE_USER'],
  database_password: ENV['DATABASE_PASSWORD'],
  secret_key_base:   ENV[SECRET_KEY_BASE_KEY_NAME],
  secret_key_base_stg: ENV[SECRET_KEY_BASE_KEY_NAME + "_STG"]
}

set :rbenv_path, '~/.rbenv'

set :keep_releases, 1 # default is 5
set :unicorn_config_path, "config/unicorn.rb"
set :unicorn_pid, "/var/run/#{ENV['PROJECT_NAME']}/unicorn/unicorn.pid"


#################### Tasks ####################
task :info do
  run_locally do
    param_list = [:pty, :stage, :application, :scm, :repo_url_, :branch, :deploy_to, :rails_env, :rbenv_path, :keep_releases]
    key_spacing = param_list.max { |a, b| a.size <=> b.size }.size
    
    param_list.each do |p|
      info "%-#{key_spacing}{key} : %{value}" % { key: p.to_s, value: fetch(p).to_s }
    end
  end
end

namespace :db do

  desc 'Create Database'
  task :create do
    on roles :db do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end

  desc 'Drop Database'
  task :drop do
    on roles :db do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:drop'
        end
      end
    end
  end

  desc 'Update Database Schema using Ridgepole'
  task :ridgepole do
    on roles :db  do
      within current_path do
        execute :bundle, :exec, :ridgepole, "-E #{fetch(:stage)} -c config/database.yml -f db/Schemafile --apply"
      end
    end
  end

end

namespace :deploy do
  desc 'Create log directories'
  task :directories do
    on roles(:app) do |host|
      ["#{fetch(:deploy_to)}",
       "/var/log/#{fetch(:application)}/rails",
       "/var/log/#{fetch(:application)}/unicorn",
       "/var/run/#{fetch(:application)}/unicorn"
      ].each do |dir|
        execute :sudo, :mkdir, '-pv', dir
        execute :sudo, :chown, '-R', 'comet:comet', dir
      end
    end
  end

  
  task :upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config ]"
        execute "mkdir -p #{shared_path}/config"
      end
      upload!('config/database.yml', "#{shared_path}/config/database.yml")
      upload!('config/secrets.yml', "#{shared_path}/config/secrets.yml")
    end
  end

  desc 'Set secret_key_base for rails'
  task :set_key do
    on roles(:app) do
      if test " [ ! -d #{shared_path}/env] "
        execute "mkdir -p #{shared_path}/env"
      end
      execute "echo #{SECRET_KEY_BASE_KEY_NAME}: #{ENV[SECRET_KEY_BASE_KEY_NAME]} > #{shared_path}/env/env.yml"
      execute "echo #{SECRET_KEY_BASE_KEY_NAME + "_STG"}: #{ENV[SECRET_KEY_BASE_KEY_NAME + "_STG"]} >> #{shared_path}/env/env.yml"
    end
  end
  
  task :symlink do
    on_rollback { run "rm #{current_path}; ln -s #{previous_release} #{current_path}"}
    run "rm #{current_path}; ln -s #{release_path} #{current_path}"
  end

  desc 'Restart unicorn'
  task :restart do
    invoke 'unicorn:restart'
  end
  
  after 'deploy:publishing', 'deploy:restart'
  before 'deploy:upload', 'deploy:directories'
  before 'deploy:starting', 'deploy:upload'
  after 'deploy:finishing', 'deploy:cleanup'

end

FILTER_PARAMETERS = [:database_password]
def filter_parameters(params)
  params.map do |k, v|
    if FILTER_PARAMETERS.include?(k)
      {k => "[FILTERED]"}
    else
      {k => v}
    end
  end
end
