require "atom/version"

module Atom

  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def create_logical_delete
      template "logical_delete.rb", "app/models/concerns/"
    end
    
  end
end
