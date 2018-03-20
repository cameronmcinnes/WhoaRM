require 'byebug'

class Validator
  attr_accessor :sql_object_class, :attr_name, :options

  MESSAGES = {
    presence: 'must be present',
    uniqueness: 'must be unique'
  }

  def initialize(sql_object_class, attr_name, options)
    @sql_object_class = sql_object_class
    @attr_name = attr_name
    @options = options
  end

  def validate(new_instance)
    attr_value = new_instance.send(attr_name)
    options.all? do |k, v|
      validation = self.send(k, v, attr_value)
      new_instance.errors[attr_name] << MESSAGES[k] unless validation
      validation
    end
  end

  def presence(bool, attr_value)
    (!!attr_value == bool) ? true : false
  end

  def uniqueness(bool, attr_value)
    
  end
end
