require 'byebug'

class Validator
  attr_accessor :sql_object_class, :attr_names, :options

  MESSAGES = {
    presence: 'must be present',
    uniqueness: 'must be unique'
  }

  def initialize(sql_object_class)
    @sql_object_class = sql_object_class
    @attr_names = sql_object_class.columns
    @options = {}
  end

  def add_validations(*attr_names, col_options)
    attr_names.each { |name| options[name] = col_options }
  end

  def validate(new_instance)
    clear_errors(new_instance)

    attr_names.all? do |attr_name|
      options[attr_name].nil? || validate_attr(attr_name, new_instance)
    end
  end


  private

  def validate_attr(attr_name, new_instance)
    attr_value = new_instance.send(attr_name)

    options[attr_name].all? do |k, v|
      valid = self.send(k, v, attr_value, attr_name)
      new_instance.errors[attr_name] << MESSAGES[k] unless valid
      valid
    end
  end

  def clear_errors(new_instance)
    new_instance.errors = Hash.new { |h, k| h[k] = [] }
  end

  def presence(bool, attr_value, _)
    (!!attr_value == bool) ? true : false
  end

  def uniqueness(bool, attr_value, attr_name)
    bool != sql_object_class.pluck(attr_name).include?(attr_value)
  end

  def numericality(bool, attr_value, _)
    bool == !!Float(attr_value) rescue false
  end
end
