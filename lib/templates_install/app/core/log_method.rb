# coding: utf-8
# メソッド実行の前後にログ出力処理を追加するモジュール
module LogMethod

  def log_method(method)
    orig = "#{method}_without_logging".to_sym
    if instance_methods.include?(orig)
      raise(NameError, "#{orig} isn't a unique name.")
    end
    
    alias_method(orig, method)
    
    define_method(method) do |*args, &block|
      Rails.logger.info "  start: #{self.class.name}.#{method}(#{LogMethod.filtered_args(*args)})"
      result = send(orig, *args, &block)
      Rails.logger.info "  end: #{self.class.name}.#{method}"
      result
    end
  end
  
  private
  
  def self.filtered_args(*args)
    if args.first != nil
      args.first.map do |k, v|
        if Rails.application.config.filter_parameters.include?(k)
          {k => "[FILTERED]"}
        else
          {k => v}
        end
      end
    end
  end
  
end
