
Rails.application.config.to_prepare do
  Permission.configure do |config|
    config.loader = PermissionLoader.new
  end
end

