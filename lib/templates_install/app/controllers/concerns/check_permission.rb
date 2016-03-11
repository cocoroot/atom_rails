
module CheckPermission extend ActiveSupport::Concern

  included do
    before_action :check_permission
  end

  private

  def check_permission
    user_info = RequestLocals.store[:request_user] || UserInfo.new

    controller = params[:controller]
    action = params[:action]

    permission = Permission.for_controller_action(controller, action)
    roles = user_info.roles

    unless roles.any? {|r| permission.include?(r) }
      raise ApplicationController::PermissionError, "user is not permitted to execute action #{controller}##{action}."
    end
  end
  
end
