require 'byebug'

class Validator
  attr_accessor :sql_object_class, :attr_name, :options

  def initialize(sql_object_class, attr_name, options)
    @sql_object_class = sql_object_class
    @attr_name = attr_name
    @options = options
  end

  def validate(new_instance)
    attr_value = new_instance.send(attr_name)
    options.all? { |k, v| self.send(k, v, attr_value) }
  end

  def presence(bool, attr_value)
    (!!attr_value == bool) ? true : false
  end

  def uniqueness(bool, new_instance)

  end
end
