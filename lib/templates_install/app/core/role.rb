
module Role
  UNAUTHENTICATED = "unauthenticated"
  API             = "api"
  MANAGER         = "manager"
  ADMIN           = "admin"
  USER            = "user"
  SYSTEM          = "system"
  
  def self.value(role)
    STATUSES[role]
  end

  def self.include?(role)
    STATUSES.include?(role)
  end

  def self.member?(role)
    self.include?(role)
  end

  def self.all
    STATUSES.keys
  end

  private

  STATUSES = {
    UNAUTHENTICATED => 11,
    API             => 21,
    MANAGER         => 31,
    ADMIN           => 32,
    USER            => 33,
    SYSTEM          => 91
  }

end
