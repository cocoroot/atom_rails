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
    end
    
    def create_app_core_dir
      dir = "#{Rails.root}/app/core"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end
    
    def create_app_logics_dir
      dir = "#{Rails.root}/app/logics"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end
    
    def create_spec_logics_dir
      dir = "#{Rails.root}/spec/logics"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

    def overwrite_database
      copy_file "config/database.yml", "config/database.yml"
    end
    
    def create_core_libraries
      directory "app/core", "app/core"
      # template "app/core/logic_base.rb", "app/core/logic_base.rb"
      # template "app/core/chain_method.rb", "app/core/chain_method.rb"
      # template "app/core/log_method.rb", "app/core/log_method.rb"
      # template "app/core/messages.rb", "app/core/messages.rb"
      # template "app/models/concerns/logical_delete.rb", "app/models/concerns/logical_delete.rb"
    end

    INJECT_SKIP_AUTHENTICATION_CODE = "  skip_before_action :verify_authenticity_token, if: :json_request?\n"
    def inject_skip_authentication_with_json_format
      insert_into_file "app/controllers/application_controller.rb", INJECT_SKIP_AUTHENTICATION_CODE, after: "protect_from_forgery with: :exception\n"
    end

    def create_error_handler
      insert_into_file "app/controllers/application_controller.rb", after: INJECT_SKIP_AUTHENTICATION_CODE do <<-'RUBY'

  class AuthenticationError < ActionController::ActionControllerError; end
      
  include ErrorHandlers

  protected

  def json_request?
    request.format.json?
  end
RUBY
      end
      
      template "app/controllers/concerns/error_handlers.rb", "app/controllers/concerns/error_handlers.rb"
      ["401", "403", "404", "500"].each do |code|
        template "app/views/errors/error#{code}.json.jbuilder", "app/views/errors/error#{code}.json.jbuilder"
      end
    end

    def logger_setting
      log_levels = {
        "development" => ":debug",
        "test" => ":debug",
        "staging" => ":info",
        "production" => ":info"
      }
      TARGET_ENVIRONMENTS.each do |env|
        insert_into_file "config/environments/#{env}.rb", after: "Rails.application.configure do\n" do <<-'RUBY'
  config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log", 'daily')

RUBY
        end
      end
      run "sed -i '' -e 's/config.log_level = :debug/config.log_level = :info/g' config/environments/production.rb"
      run "sed -i '' -e 's/config.log_level = :debug/config.log_level = :info/g' config/environments/staging.rb"
      
      application nil, env: "development" do
        "config.log_level = :debug"
      end

      application nil, env: "test" do
        "config.log_level = :debug"
      end
    end

    def create_schema_file_and_dir
      template "db/Schemafile", "db/Schemafile"
      dir = "#{Rails.root}/db/schema"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

    def rspec_init
      run "#{File.join("bin", "rails")} generate rspec:install"
    end

    def overwrite_spec_helper
      template "spec/spec_helper.rb", "spec/spec_helper.rb"
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
      template "app/controllers/concerns/dbaas_authentication.rb", "app/controllers/concerns/dbaas_authentication.rb"

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
