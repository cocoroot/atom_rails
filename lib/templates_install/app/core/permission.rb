# coding: utf-8
module Permission
  # config/initializers/permission.rb
  # にてインスタンス化した PermissionLoader を Permission が保持する
  include ActiveSupport::Configurable
  config_accessor :loader

  def self.all
    self.loader.permissions
  end
  
  # コントローラ名を文字列で受け取り、
  # 当該コントローラの permission を Hash で全て返す。
  #
  # return 例：
  #
  # {
  #   "xxx_xxx(コントローラ名)" => {
  #     "create" => ["manager"],
  #     "show"   => ["manager", "user", "admin"],
  #     ...
  #   },
  #   "yyy_yyy(コントローラ名)" => {
  #     ...
  #   },
  #   ...
  # }
  #
  # 対象の permission 設定が config/permission.yml に存在しない場合、空の Hash を返す。
  #
  # 例えば、コントローラのファイル名が my_books_controller.rb である場合、
  # 引数にはは "my_books" または "MyBooks" いずれかを渡す。
  #
  def self.for_controller(controller)
    c = controller.underscore
    
    permissions = self.loader.permissions
    if permissions.include? c
      permissions[c]
    else
      {}
    end
  end

  # コントローラ名とアクション名を文字列で受け取り、
  # 指定されたアクションの permission を Array で返す。
  def self.for_controller_action(controller, action)
    c = controller.underscore
    a = action.downcase

    permissions = self.loader.permissions
    if permissions.include? c
      if permissions[c].include? a
        return permissions[c][a]
      end
    end
    []
  end

end
