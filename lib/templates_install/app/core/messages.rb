
#module DCore
class Messages
  include Enumerable

  attr_reader :messages

  # Pass in the instance of the object that is using the errors object.
  #
  #   class Person
  #     def initialize
  #       @errors = ActiveModel::Errors.new(self)
  #     end
  #   end
  def initialize #(base)
    # @base     = base
    @messages = {}
  end

  def initialize_dup(other) # :nodoc:
    @messages = other.messages.dup
    super
  end

  # Clear the error messages.
  #
  #   person.errors.full_messages # => ["name cannot be nil"]
  #   person.errors.clear
  #   person.errors.full_messages # => []
  def clear
    messages.clear
  end

  # Returns +true+ if the error messages include an error for the given key
  # +attribute+, +false+ otherwise.
  #
  #   person.errors.messages        # => {:name=>["cannot be nil"]}
  #   person.errors.include?(:name) # => true
  #   person.errors.include?(:age)  # => false
  def include?(attribute)
    messages[attribute].present?
  end
  # aliases include?
  alias :has_key? :include?
  # aliases include?
  alias :key? :include?

  # Get messages for +key+.
  #
  #   person.errors.messages   # => {:name=>["cannot be nil"]}
  #   person.errors.get(:name) # => ["cannot be nil"]
  #   person.errors.get(:age)  # => nil
  def get(key)
    messages[key]
  end

  # Set messages for +key+ to +value+.
  #
  #   person.errors.get(:name) # => ["cannot be nil"]
  #   person.errors.set(:name, ["can't be nil"])
  #   person.errors.get(:name) # => ["can't be nil"]
  def set(key, value)
    messages[key] = value
  end

  # Delete messages for +key+. Returns the deleted messages.
  #
  #   person.errors.get(:name)    # => ["cannot be nil"]
  #   person.errors.delete(:name) # => ["cannot be nil"]
  #   person.errors.get(:name)    # => nil
  def delete(key)
    messages.delete(key)
  end

  # When passed a symbol or a name of a method, returns an array of errors
  # for the method.
  #
  #   person.errors[:name]  # => ["cannot be nil"]
  #   person.errors['name'] # => ["cannot be nil"]
  def [](attribute)
    get(attribute.to_sym) || set(attribute.to_sym, [])
  end

  # Adds to the supplied attribute the supplied error message.
  #
  #   person.errors[:name] = "must be set"
  #   person.errors[:name] # => ['must be set']
  def []=(attribute, error)
    self[attribute] << error
  end

  # Iterates through each error key, value pair in the error messages hash.
  # Yields the attribute and the error for that attribute. If the attribute
  # has more than one error message, yields once for each error message.
  #
  #   person.errors.add(:name, "can't be blank")
  #   person.errors.each do |attribute, error|
  #     # Will yield :name and "can't be blank"
  #   end
  #
  #   person.errors.add(:name, "must be specified")
  #   person.errors.each do |attribute, error|
  #     # Will yield :name and "can't be blank"
  #     # then yield :name and "must be specified"
  #   end
  def each
    messages.each_key do |attribute|
      self[attribute].each { |error| yield attribute, error }
    end
  end

  # Returns the number of error messages.
  #
  #   person.errors.add(:name, "can't be blank")
  #   person.errors.size # => 1
  #   person.errors.add(:name, "must be specified")
  #   person.errors.size # => 2
  def size
    values.flatten.size
  end

  # Returns all message values.
  #
  #   person.errors.messages # => {:name=>["cannot be nil", "must be specified"]}
  #   person.errors.values   # => [["cannot be nil", "must be specified"]]
  def values
    messages.values
  end

  # Returns all message keys.
  #
  #   person.errors.messages # => {:name=>["cannot be nil", "must be specified"]}
  #   person.errors.keys     # => [:name]
  def keys
    messages.keys
  end

  # Returns an array of error messages, with the attribute name included.
  #
  #   person.errors.add(:name, "can't be blank")
  #   person.errors.add(:name, "must be specified")
  #   person.errors.to_a # => ["name can't be blank", "name must be specified"]
  def to_a
    full_messages
  end

  # Returns the number of error messages.
  #
  #   person.errors.add(:name, "can't be blank")
  #   person.errors.count # => 1
  #   person.errors.add(:name, "must be specified")
  #   person.errors.count # => 2
  def count
    to_a.size
  end

  # Returns +true+ if no errors are found, +false+ otherwise.
  # If the error message is a string it can be empty.
  #
  #   person.errors.full_messages # => ["name cannot be nil"]
  #   person.errors.empty?        # => false
  def empty?
    all? { |k, v| v && v.empty? && !v.is_a?(String) }
  end
  # aliases empty?
  alias_method :blank?, :empty?

  # Returns an xml formatted representation of the Errors hash.
  #
  #   person.errors.add(:name, "can't be blank")
  #   person.errors.add(:name, "must be specified")
  #   person.errors.to_xml
  #   # =>
  #   #  <?xml version=\"1.0\" encoding=\"UTF-8\"?>
  #   #  <errors>
  #   #    <error>name can't be blank</error>
  #   #    <error>name must be specified</error>
  #   #  </errors>
  def to_xml(options={})
    to_a.to_xml({ root: "errors", skip_types: true }.merge!(options))
  end

  # Returns a Hash that can be used as the JSON representation for this
  # object. You can pass the <tt>:full_messages</tt> option. This determines
  # if the json object should contain full messages or not (false by default).
  #
  #   person.errors.as_json                      # => {:name=>["cannot be nil"]}
  #   person.errors.as_json(full_messages: true) # => {:name=>["name cannot be nil"]}
  def as_json(options=nil)
    to_hash(options && options[:full_messages])
  end

  # Returns a Hash of attributes with their error messages. If +full_messages+
  # is +true+, it will contain full messages (see +full_message+).
  #
  #   person.errors.to_hash       # => {:name=>["cannot be nil"]}
  #   person.errors.to_hash(true) # => {:name=>["name cannot be nil"]}
  def to_hash(full_messages = false)
    if full_messages
      self.messages.each_with_object({}) do |(attribute, array), messages|
        messages[attribute] = array.map { |message| full_message(attribute, message) }
      end
    else
      self.messages.dup
    end
  end

  # Adds +message+ to the error messages on +attribute+. More than one error
  # can be added to the same +attribute+. If no +message+ is supplied,
  # <tt>:invalid</tt> is assumed.
  #
  #   person.errors.add(:name)
  #   # => ["is invalid"]
  #   person.errors.add(:name, 'must be implemented')
  #   # => ["is invalid", "must be implemented"]
  #
  #   person.errors.messages
  #   # => {:name=>["must be implemented", "is invalid"]}
  #
  # If +message+ is a symbol, it will be translated using the appropriate
  # scope (see +generate_message+).
  #
  # If +message+ is a proc, it will be called, allowing for things like
  # <tt>Time.now</tt> to be used within an error.
  #
  # If the <tt>:strict</tt> option is set to +true+, it will raise
  # ActiveModel::StrictValidationFailed instead of adding the error.
  # <tt>:strict</tt> option can also be set to any other exception.
  #
  #   person.errors.add(:name, nil, strict: true)
  #   # => ActiveModel::StrictValidationFailed: name is invalid
  #   person.errors.add(:name, nil, strict: NameIsInvalid)
  #   # => NameIsInvalid: name is invalid
  #
  #   person.errors.messages # => {}
  #
  # +attribute+ should be set to <tt>:base</tt> if the error is not
  # directly associated with a single attribute.
  #
  #   person.errors.add(:base, "either name or email must be present")
  #   person.errors.messages
  #   # => {:base=>["either name or email must be present"]}
  def add(attribute, message = :invalid, options = {})
    message = normalize_message(attribute, message, options)
    if exception = options[:strict]
      exception = ActiveModel::StrictValidationFailed if exception == true
      raise exception, full_message(attribute, message)
    end

    self[attribute] << message
  end

  def <<(messages, options = {})
    messages.each do |k, v|
      self[k].concat(v)
    end
  end

  # Will add an error message to each of the attributes in +attributes+
  # that is empty.
  #
  #   person.errors.add_on_empty(:name)
  #   person.errors.messages
  #   # => {:name=>["can't be empty"]}
  # def add_on_empty(attributes, options = {})
  #   Array(attributes).each do |attribute|
  #     value = @base.send(:read_attribute_for_validation, attribute)
  #     is_empty = value.respond_to?(:empty?) ? value.empty? : false
  #     add(attribute, :empty, options) if value.nil? || is_empty
  #   end
  # end

  # Will add an error message to each of the attributes in +attributes+ that
  # is blank (using Object#blank?).
  #
  #   person.errors.add_on_blank(:name)
  #   person.errors.messages
  #   # => {:name=>["can't be blank"]}
  # def add_on_blank(attributes, options = {})
  #   Array(attributes).each do |attribute|
  #     value = @base.send(:read_attribute_for_validation, attribute)
  #     add(attribute, :blank, options) if value.blank?
  #   end
  # end

  # Returns +true+ if an error on the attribute with the given message is
  # present, +false+ otherwise. +message+ is treated the same as for +add+.
  #
  #   person.errors.add :name, :blank
  #   person.errors.added? :name, :blank # => true
  def added?(attribute, message = :invalid, options = {})
    message = normalize_message(attribute, message, options)
    self[attribute].include? message
  end

  # Returns all the full error messages in an array.
  #
  #   class Person
  #     validates_presence_of :name, :address, :email
  #     validates_length_of :name, in: 5..30
  #   end
  #
  #   person = Person.create(address: '123 First St.')
  #   person.errors.full_messages
  #   # => ["Name is too short (minimum is 5 characters)", "Name can't be blank", "Email can't be blank"]
  def full_messages
    map { |attribute, message| full_message(attribute, message) }
  end

  # Returns all the full error messages for a given attribute in an array.
  #
  #   class Person
  #     validates_presence_of :name, :email
  #     validates_length_of :name, in: 5..30
  #   end
  #
  #   person = Person.create()
  #   person.errors.full_messages_for(:name)
  #   # => ["Name is too short (minimum is 5 characters)", "Name can't be blank"]
  def full_messages_for(attribute)
    (get(attribute) || []).map { |message| full_message(attribute, message) }
  end

  # Returns a full message for a given attribute.
  #
  #   person.errors.full_message(:name, 'is invalid') # => "Name is invalid"
  def full_message(attribute, message)
    return message if attribute == :base
    attr_name = attribute.to_s.tr('.', '_').humanize
    #attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
    I18n.t(:"errors.format", {
             default:  "%{attribute} %{message}",
             attribute: attr_name,
             message:   message
           })
  end

  private
  def normalize_message(attribute, message, options)
    # case message
    # when Symbol
    #   generate_message(attribute, message, options.except(*CALLBACKS_OPTIONS))
    # when Proc
    #   message.call
    # else
    #   message
    # end
    message
  end

end
# Raised when a validation cannot be corrected by end users and are considered
# exceptional.
#
#   class Person
#     include ActiveModel::Validations
#
#     attr_accessor :name
#
#     validates_presence_of :name, strict: true
#   end
#
#   person = Person.new
#   person.name = nil
#   person.valid?
#   # => ActiveModel::StrictValidationFailed: Name can't be blank
class StrictValidationFailed < StandardError
end
#end
