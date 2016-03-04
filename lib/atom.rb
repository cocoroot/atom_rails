require "atom/version"

module Atom

  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def create_app_core_dir
      dir = "#{Rails.root}/app/core"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
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
