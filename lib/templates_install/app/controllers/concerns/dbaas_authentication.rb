
require 'net/http'
require 'uri'
require 'json'

module DbaasAuthentication extend ActiveSupport::Concern

  included do
    before_action :verify_access_token
  end
  
  private

  # verify access token which http request header contains.
  def verify_access_token
    #
    # build request
    #
    api = "https://#{Settings.dbaas.api_url}/apps/#{Settings.dbaas.app_id}/users/me/status"
    uri = URI.parse(api)
    
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    token = request.headers[:HTTP_ACCESS_TOKEN]

    req = Net::HTTP::Get.new(uri.request_uri)
    req["X-Kii-AppID"] = Settings.dbaas.app_id
    req["X-Kii-AppKey"] = Settings.dbaas.app_key
    req["Authorization"] = "Bearer #{token}" if valid_token?(token)

    
    #
    # send request
    #
    response = https.request(req)

    Rails.logger.debug response.code
    Rails.logger.debug response.message
    Rails.logger.debug response.body
    
    if response.code != '200'
      raise ApplicationController::AuthenticationError, response.code
    end

  end

  def valid_token?(token)
    token =~ /^[a-zA-z0-9\-_]+$/ ? true : false
  end

end
