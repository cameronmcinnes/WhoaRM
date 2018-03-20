require_relative 'sql_object'
require_relative 'validator'

require 'byebug'

# call validates in initialize of SQLObject

module Validatable
  attr_reader :errors

  def self.validates(attr_name, options)
    # save the new validator object as a CLASS INSTANCE variable
    # then from the sql object initialize call the validate method
    # in the validator class
    self.validator = Validator.new(self, attr_name, options)
  end

  def valid?
    self.class.validator.validate(self)
  end
end
