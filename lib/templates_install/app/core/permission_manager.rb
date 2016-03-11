# coding: utf-8

class PermissionManager
  attr_reader :permissions
  
  def initialize
    @permissions = YAML.load_file('config/permission.yml')
    @permissions = {} if @permissions == false
    @permissions.each_value { |controller|
      raise "format error in permission.yml: controller has to have a hash" unless controller.is_a? Hash
      controller.each_value { |action|
        raise "format error in permission.yml: action has to have an array." unless action.is_a? Array
        action.map!(&:freeze).freeze unless action.frozen?
      }
      controller.freeze unless controller.frozen?
    }
    @permissions.freeze
  end

end

