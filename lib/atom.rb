require "atom/version"
require "rails/generators"

module Atom

  TARGET_ENVIRONMENTS = ["development", "test", "staging", "production"].freeze
    
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates_install', __FILE__)

    def add_gems
      gem 'enumerize'
      gem 'ridgepole'
      gem 'config'
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
      gem_group :development do
        gem "capistrano"
        gem "capistrano-rbenv", :git => 'https://github.com/capistrano/rbenv.git'
        gem "capistrano-rails"
        gem "capistrano-postgresql"
        gem "capistrano-bundler"
        gem "capistrano3-unicorn" 
      end
      
      Bundler.with_clean_env do
        run 'bundle install', capture: true
      end
    end

    def config_init
      run "#{File.join("bin", "rails")} generate config:install"
      FileUtils.touch('config/settings/staging.yml')
    end

    def create_staging_env
      FileUtils.copy_file('config/environments/production.rb', 'config/environments/staging.rb')
      append_to_file 'config/secrets.yml' do <<-RUBY

staging:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
RUBY
      end
    end

    def create_directories
      empty_directory 'app/core'
      empty_directory 'app/logics'
      empty_directory 'spec/logics'
    end
    
    # def create_app_core_dir
    #   dir = "#{Rails.root}/app/core"
    #   FileUtils.mkdir_p(dir) unless File.directory?(dir)
    # end
    
    # def create_app_logics_dir
    #   dir = "#{Rails.root}/app/logics"
    #   FileUtils.mkdir_p(dir) unless File.directory?(dir)
    # end
    
    # def create_spec_logics_dir
    #   dir = "#{Rails.root}/spec/logics"
    #   FileUtils.mkdir_p(dir) unless File.directory?(dir)
    # end

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
      insert_into_file "app/controllers/application_controller.rb", after: INJECT_SKIP_AUTHENTICATION_CODE do <<-'RUBY'

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
      insert_into_file "app/controllers/application_controller.rb", after: "  include ErrorHandlers\n" do <<-RUBY
  include CheckPermission
RUBY
      end
      copy_file "app/controllers/concerns/check_permission.rb", "app/controllers/concerns/check_permission.rb"
      copy_file "config/permission.yml", "config/permission.yml"
      copy_file "config/initializers/permission.rb", "config/initializers/permission.rb"
    end

    def logger_setting
      log_levels = {
        "development" => ":debug",
        "test" => ":debug",
        "staging" => ":info",
        "production" => ":info"
      }

      ["staging", "production"].each do |env|
        comment_lines "config/environments/#{env}.rb", /config.log_level = :debug/
      end

      TARGET_ENVIRONMENTS.each do |env|
        application nil, env: env do
          "config.logger = ActiveSupport::Logger.new(\"log/#{Rails.env}.log\", 'daily')"
          "config.log_level = #{log_levels[env]}"
        end
      end
    end

    def create_schema_file_and_dir
      copy_file "db/Schemafile", "db/Schemafile"
      dir = "#{Rails.root}/db/schema"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

    def rspec_init
      run "#{File.join("bin", "rails")} generate rspec:install"
    end

    def overwrite_spec_helper
      copy_file "spec/spec_helper.rb", "spec/spec_helper.rb"
    end

    def gitignore_coverage
      append_to_file '.gitignore', '/coverage'
    end

    def create_seed_dir
      TARGET_ENVIRONMENTS.each do |env|
        dir = "#{Rails.root}/db/seeds/#{env}"
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
      end
    end
    
  end

  
  class DbaasGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates_baas', __FILE__)

    def dbaas_authentication
      copy_file "app/controllers/concerns/dbaas_authentication.rb", "app/controllers/concerns/dbaas_authentication.rb"

      insert_into_file "app/controllers/application_controller.rb", "  include DbaasAuthentication\n", after: "  include ErrorHandlers\n"

      TARGET_ENVIRONMENTS.each do |env|
        append_to_file "config/settings/#{env}.yml", <<RUBY
dbaas:
  api_url: <%= ENV['DBAAS_API_URL'] %>
  app_id:  <%= ENV['DBAAS_APP_ID'] %>
  app_key: <%= ENV['DBAAS_APP_KEY'] %>

RUBY
      end
    end
  end
end
