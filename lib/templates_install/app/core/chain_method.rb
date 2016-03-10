module ChainMethod

  def chain_method(*methods)
    succeeding = methods.first[:before]
    preceding  = methods.first[:insert]
    #Rails.logger.debug "insert method #{preceding} before #{succeeding}"

    orig = "#{succeeding}_without_chain".to_sym
    if instance_methods.include?(orig)
      raise(NameError, "#{orig} isn't a unique method.")
    end

    alias_method(orig, succeeding)

    define_method(succeeding) do |*args, &block|
      #Rails.logger.debug "  logic method call: #{preceding}"

      send(preceding, *args, &block)

      errors = instance_variable_get(:@errors)
      warnings = instance_variable_get(:@warnings)
      return { errors: errors, warnings: warnings } if !errors.empty?
      #Rails.logger.debug "  logic method call: #{orig}"

      send(orig, *args, &block)
    end

  end

end
