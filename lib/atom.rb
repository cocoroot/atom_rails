# coding: utf-8
require "atom/version"
require "rails/generators"

class String
  def ~
        margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end
end

module Atom
  TARGET_ENVIRONMENTS = ["development", "test", "staging", "production"].freeze

  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates_install', __FILE__)

    def config_init
      run "#{File.join("bin", "rails")} generate config:install"
      FileUtils.touch('config/settings/staging.yml')
    end

    def create_staging_env
      FileUtils.copy_file('config/environments/production.rb', 'config/environments/staging.rb')
      append_to_file 'config/secrets.yml' do ~<<-RUBY
        
        staging:
          secret_key_base: <%= ENV[\"SECRET_KEY_BASE_STG\"] %>
        
      RUBY
      end
    end

    def create_directories
      empty_directory 'app/core'
      empty_directory 'app/logics'
      empty_directory 'spec/logics'
    end
    
    def overwrite_database
      copy_file "config/database.yml", "config/database.yml"
    end
    
    def create_core_libraries
      directory "app/core", "app/core"
    end

    INJECT_SKIP_AUTHENTICATION_CODE = "  skip_before_action :verify_authenticity_token, if: :json_request?\n"
    def inject_skip_authentication_with_json_format
      insert_into_file "app/controllers/application_controller.rb", INJECT_SKIP_AUTHENTICATION_CODE, after: "protect_from_forgery with: :exception\n"
    end

    def error_handler
      insert_into_file "app/controllers/application_controller.rb", after: INJECT_SKIP_AUTHENTICATION_CODE do ~<<-RUBY
      
        class AuthenticationError < ActionController::ActionControllerError; end
        
        include ErrorHandlers
        
        protected
        
        def json_request?
          request.format.json?
        end
      
      RUBY
      end
      
      copy_file "app/controllers/concerns/error_handlers.rb", "app/controllers/concerns/error_handlers.rb"
      ["401", "403", "404", "500"].each do |code|
        copy_file "app/views/errors/error#{code}.json.jbuilder", "app/views/errors/error#{code}.json.jbuilder"
      end
    end

    def check_permission
      insert_into_file "app/controllers/application_controller.rb", after: "  class AuthenticationError < ActionController::ActionControllerError; end\n" do 
        "  class PermissionError < ActionController::ActionControllerError; end\n"
      end
      
      insert_into_file "app/controllers/application_controller.rb", after: "  include ErrorHandlers\n" do
        "  include CheckPermission\n"
      end
      copy_file "app/controllers/concerns/check_permission.rb", "app/controllers/concerns/check_permission.rb"
      copy_file "config/permission.yml", "config/permission.yml"
      copy_file "config/initializers/permission.rb", "config/initializers/permission.rb"
    end

    def logger_setting
      app_name = Rails.application.class.parent_name.split('/').last.underscore
      settings = {
        "test"        => { level: ":debug", dest: "log" },
        "development" => { level: ":debug", dest: "log" },
        "staging"     => { level: ":info",  dest: "/var/log/#{app_name}/rails" },
        "production"  => { level: ":info",  dest: "/var/log/#{app_name}/rails" }
      }

      TARGET_ENVIRONMENTS.each do |env|
        gsub_file "config/environments/#{env}.rb", /config.log_level = :debug/, ''
        application nil, env: env do ~<<-RUBY
          config.log_level = #{settings[env][:level]}
        RUBY
        end
        application nil, env: env do ~<<-RUBY
          config.logger = ActiveSupport::Logger.new(\"#{settings[env][:dest]}/\#{Rails.env}.log\")
        RUBY
        end
      end
    end

    def create_schema_file_and_dir
      copy_file "db/Schemafile", "db/Schemafile"
      empty_directory 'db/schema'
    end

    def rspec_init
      run "#{File.join("bin", "rails")} generate rspec:install"
    end

    def overwrite_spec_helper
      copy_file "spec/spec_helper.rb", "spec/spec_helper.rb"
    end

    def setup_capistrano
      app_name = Rails.application.class.parent_name.split('/').last.underscore
      empty_directory 'config/deploy'
      empty_directory 'lib/capistrano/tasks'
      run 'bundle exec cap install STAGES=development,staging,production'
      copy_file "Capfile", "Capfile"
      copy_file "config/deploy.rb", "config/deploy.rb"
      
      ["development", "staging"].each do |env| # production モードで直接デプロイすることはない
        append_to_file "config/deploy/#{env}.rb" do ~<<-RUBY
          server ENV['TARGET_SERVER'], user: 'comet', roles: %w{app db}
          set :rails_env, :#{env}
          set :unicorn_rack_env, :#{env}
        RUBY
        end
      end
    end

    def setup_unicorn
      copy_file "config/unicorn.rb", "config/unicorn.rb"
    end

    def gitignore_coverage
      append_to_file '.gitignore', '/coverage'
    end

    def create_seed_dir
      TARGET_ENVIRONMENTS.each do |env|
        empty_directory "#{Rails.root}/db/seeds/#{env}"
      end
    end

    def initial_commit
      run 'git init .', capture: true
      run 'git add .', capture: true
      run 'git commit -a -m "initial commit."', capture: true
    end
    
  end

  
  class DbaasGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates_baas', __FILE__)

    def dbaas_authentication
      copy_file "app/controllers/concerns/dbaas_authentication.rb", "app/controllers/concerns/dbaas_authentication.rb"

      insert_into_file "app/controllers/application_controller.rb", "  include DbaasAuthentication\n", after: "  include ErrorHandlers\n"

      TARGET_ENVIRONMENTS.each do |env|
        append_to_file "config/settings/#{env}.yml", ~<<-RUBY
          dbaas:
            api_url: <%= ENV['DBAAS_API_URL'] %>
            app_id:  <%= ENV['DBAAS_APP_ID'] %>
            app_key: <%= ENV['DBAAS_APP_KEY'] %>
      
      RUBY
      end
    end
  end
end
