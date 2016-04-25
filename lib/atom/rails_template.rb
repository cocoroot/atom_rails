
#gem 'atom', git: 'https://sdp.nbws.jp/dreg-gitlab/SPF-DREGroup/atom_rails.git'
gem 'atom', path: '../atom'

gem 'enumerize'
gem 'ridgepole'
gem 'config', '1.0'
gem 'unicorn'
gem 'hirb'
gem 'hirb-unicode'
gem 'request_store_rails'
gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'simplecov', :require => false
end
gem_group :deployment do
  gem 'capistrano'
  gem 'capistrano-rbenv', :git => 'https://github.com/capistrano/rbenv.git'
  gem 'capistrano-rails'
  gem 'capistrano-postgresql'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn' 
end

run 'bundle install --quiet'

generate 'atom:install', '-f'
