
Rails.application.config.to_prepare do
  Permission.configure do |config|
    config.manager = PermissionManager.new
  end
end

