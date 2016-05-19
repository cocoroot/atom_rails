require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    class SchemafileGenerator < ActiveRecord::Generators::ModelGenerator
      source_root "#{base_root}/active_record/model/templates"

      def create_schema_file
        return unless options[:migration] && options[:parent].nil?
        attributes.each { |a| a.attr_options.delete(:index) if a.reference? && !a.has_index? } if options[:indexes] == false
        migration_template "#{File.expand_path('../templates', __FILE__)}/create_table_schemafile.rb", "db/schema/create_#{table_name}.rb"
      end

      def rename_migration_files
        Dir['db/migrate/*.rb'].each { |file| File.rename(File.expand_path(file), File.expand_path(file) + '.bak') }
      end
    end
  end
end
