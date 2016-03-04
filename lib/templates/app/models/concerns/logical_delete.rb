module LogicalDelete
  extend ActiveSupport::Concern

  def logical_delete
    self.removed_at = Time.now
    self.removed_id = self.id
  end

  included do
    default_scope { where("removed_id is null") }
  end
  
end
