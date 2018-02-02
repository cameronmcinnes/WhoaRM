require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    case class_name
    when "Human"
      "#{class_name.downcase}s"
    else
      class_name.tableize
    end
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelcase,
      foreign_key: "#{name.to_s.singularize.underscore}_id".to_sym,
      primary_key: :id
    }

    options = defaults.merge(options)

    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      class_name: name.to_s.singularize.camelcase,
      foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym,
      primary_key: :id
    }

    options = defaults.merge(options)

    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # name is the association name
    options = BelongsToOptions.new(name, options)

    # store these options by target class name
    assoc_options[name] = options

    define_method(name) do
      # can't fk foreign key because then we're using setting method?
      fk = options.foreign_key.to_sym
      foreign_val = self.send(fk)

      target_class = options.model_class
      target_class.where({ id: foreign_val }).first
    end
  end

  def has_many(name, options = {})
    self_class_name = self
    has_many_options = HasManyOptions.new(name, self_class_name, options)

    define_method(name) do

      fk = has_many_options.foreign_key.to_sym
      target_class = has_many_options.model_class

      target_class.where({ fk => self.id })
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end


class SQLObject
  extend Associatable
end
