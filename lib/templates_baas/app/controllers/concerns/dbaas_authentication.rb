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
    # receive token
    #
    token = request.headers[:HTTP_ACCESS_TOKEN]
    token = (valid_token?(token) ? token : "")
    
    #
    # build request
    #
    api_base = Settings.dbaas.api_url
    app_id = Settings.dbaas.app_id
    api = "#{api_base}/apps/#{app_id}/server-code/versions/current/user_attributes"
    uri = URI.parse(api)
    
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    req = Net::HTTP::Post.new(uri.request_uri)
    req["X-Kii-AppID"] = Settings.dbaas.app_id
    req["X-Kii-AppKey"] = Settings.dbaas.app_key
    req["Content-Type"] = "application/json"
    req.body = {
      "access_token" => token
    }.to_json
    
    #
    # send request
    #
    res = https.request(req)

    #
    # make response
    #
    ret = JSON.parse(res.body)["returnedValue"]
    if ret["status"] == 'OK'
      RequestLocals.store[:request_user] = ret["user"]
    else
      raise ApplicationController::AuthenticationError, response.code
    end
  end
  
  def valid_token?(token)
    token =~ /^[a-zA-z0-9\-_]+$/ ? true : false
  end
  
end
