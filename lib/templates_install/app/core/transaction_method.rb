
module TransactionMethod

  def transaction_method(method)
    orig = "#{method}_without_transaction".to_sym
    if instance_methods.include?(orig)
      raise(NameError, "#{orig} isn't a unique name.")
    end
    
    alias_method(orig, method)
    
    define_method(method) do |*args, &block|
      result = {}
      ActiveRecord::Base.transaction do
        result = send(orig, *args, &block)
      end
      result
    end
  end
  
end

