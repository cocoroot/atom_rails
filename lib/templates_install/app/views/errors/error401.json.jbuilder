# coding: utf-8
json.status 401
json.errors do |json|
  json.message_code "unauthorized"
  json.message "アクセスは認証されていません。"
end
