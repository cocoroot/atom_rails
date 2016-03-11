
class UserInfo

  attr_reader :ex_user_id
  attr_reader :roles

  def initialize(id = "", roles = [Role::UNAUTHENTICATED])
    @ex_user_id = id
    
    @roles = Set.new
    roles.each do |role|
      @roles << role if Role.include?(role)
    end
  end
  
end
