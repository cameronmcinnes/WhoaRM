require_relative "sql_object"

# is there a solution where relation inherits from array class?
# would need to override all array instance methods

class Relation
  attr_reader :params

  def initialize(class_name, params)
    @class_name = class_name
    @params = params
  end

  # makes stackable
  def where(new_params)
    add_params(new_params)
    self
  end

  # query will only execute if a valid array method is called
  # on the relation object.
  def method_missing(method_name, *args, &blk)
    if Array.instance_methods.include?(method_name)
      # call the actual array method on the parsed result arr
      execute_query.send(method_name, *args, &blk)
    else
      super
    end
  end



  private

  def execute_query
    # allows method to take raw SQL string or options hash
    if params.is_a?(Hash)
      results = hash_query
    elsif params.is_a?(String)
      results = str_query
    end

    @class_name.parse_all(results)
  end

  def str_query
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{@class_name.table_name}
      WHERE
        #{params}
    SQL
  end

  def hash_query
    where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{@class_name.table_name}
      WHERE
        #{where_line}
    SQL
  end

  # todo: add conditional that allows chaining of raw SQL str methods
  def add_params(new_params)
    @params = @params.merge(new_params)
  end
end
