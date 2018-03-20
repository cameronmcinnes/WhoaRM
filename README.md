# GoRM
### A lightweight Ruby ORM

## Features
GoRM is a lightweight ORM
ability to update and save records
basic associations
has_one through association
lazy stackable where queries
pluck
pluck stackable on where
uniqueness, presence, numericality, validations

## Future Directions
has many through
includes
joins
accepts nested attributes for
polymorphic associations

```` javascript
module Validatable
  def self.included(base)
    base.extend(ClassMethods)
  end

  attr_accessor :errors

  def valid?
    self.class.validator ? self.class.validator.validate(self) : true
  end

  private
  module ClassMethods
    def validates(*attr_names, options)
      self.validator ||= Validator.new(self)
      self.validator.add_validations(*attr_names, options)
    end
  end
end
````

```` javascript
def method_missing(method_name, *args, &blk)
  if Array.instance_methods.include?(method_name)
    # call the actual array method on the parsed result arr
    execute_query.send(method_name, *args, &blk)
  else
    super
  end
end
````

```` javascript
results = DBConnection.execute(<<-SQL, *params.values)
  SELECT
    #{sql_object_class.table_name}.#{pluck_column}
  FROM
    #{sql_object_class.table_name}
  WHERE
    #{where_line}
SQL
````

```` javascript
def uniqueness(bool, new_instance, attr_name)
  attr_value = new_instance.send(attr_name)

  if new_instance.id.nil?
    col_vals = sql_object_class.pluck(attr_name)
  else
    col_vals = sql_object_class.where("NOT id = #{new_instance.id}").
      pluck(attr_name)
  end

  bool != col_vals.include?(attr_value)
end
````
