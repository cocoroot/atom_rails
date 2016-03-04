require "atom/version"

module Atom

  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def add_gems
      gem 'devise' #
      gem 'enumerize'
      gem 'ridgepole' #
      gem 'unicorn' #
      gem 'hirb' #
      gem 'hirb-unicode' #
      gem_group :development, :test do
        gem 'rspec-rails' #
        gem 'factory_girl_rails' #
        gem 'database_cleaner' #
        gem 'pry-rails' #
        gem 'pry-doc'
        gem 'simplecov', :require => false #
      end
      gem_group :development do
        gem "capistrano" #
        gem "capistrano-rbenv", :git => 'https://github.com/capistrano/rbenv.git' #
        gem "capistrano-rails" #
        gem "capistrano-postgresql" #
        gem "capistrano-bundler" #
        gem "capistrano3-unicorn" 
      end
    end
    
    def create_app_core_dir
      dir = "#{Rails.root}/app/core"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

    def overwrite_database
      copy_file "config/database.yml", "config/database.yml"
    end
    
    def create_logic_base
      template "app/core/logic_base.rb", "app/core/logic_base.rb"
    end

    def create_chain_method
      template "app/core/chain_method.rb", "app/core/chain_method.rb"
    end

    def create_log_method
      template "app/core/log_method.rb", "app/core/log_method.rb"
    end

    def create_messages
      template "app/core/messages.rb", "app/core/messages.rb"
    end
    
    def create_logical_delete
      template "app/models/concerns/logical_delete.rb", "app/models/concerns/logical_delete.rb"
    end
    
  end
end
