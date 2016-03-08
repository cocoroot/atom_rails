class LogicBase
  extend LogMethod
  extend ChainMethod

  PERMITTED_LOGIC_METHODS = [:authorize, :validate, :execute]

  def self.method_added(method)
    @treated_methods ||= []
    if PERMITTED_LOGIC_METHODS.include?(method) && !@treated_methods.include?(method)
      @treated_methods << method
      if @treated_methods.count == PERMITTED_LOGIC_METHODS.count
        self.chain_method(insert: :authorize, before: :validate)
        self.chain_method(insert: :validate, before: :execute)
        self.log_method(:execute)
      end
    end
  end

  def initialize
    @errors = Messages.new
    @warnings = Messages.new
  end

  protected
  attr_accessor :treated_methods
end

