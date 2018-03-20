require_relative 'searchable'
require 'active_support/inflector'

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
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_id = self.send(through_options.foreign_key)

      result = DBConnection.execute(<<-SQL, through_id)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{through_options.table_name}
        JOIN
          #{source_options.table_name}
        ON #{through_options.table_name}.#{source_options.foreign_key.to_s}
          = #{source_options.table_name}.#{source_options.primary_key.to_s}
        WHERE
          #{through_options.table_name}.#{through_options.primary_key.to_s} = ?
      SQL

      source_options.class_name.constantize.new(result.first)
    end
  end

  def has_many_through(name, through_name, source_name)
    
  end
end
