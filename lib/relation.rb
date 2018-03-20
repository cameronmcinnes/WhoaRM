require_relative "sql_object"

# is there a solution where relation inherits from array class?
# would need to override all array instance methods

class Relation
  attr_reader :params, :sql_object_class

  def initialize(sql_object_class, params)
    @sql_object_class = sql_object_class
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
    results = params.is_a?(Hash) ? hash_query : str_query

    sql_object_class.parse_all(results)
  end

  def str_query
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{sql_object_class.table_name}
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
        #{sql_object_class.table_name}
      WHERE
        #{where_line}
    SQL
  end

  # todo: enable chaining of hash and string querys together
  def add_params(new_params)
    if new_params.is_a?(Hash)
      params = params.merge(new_params)
    elsif new_params.is_a?(String)
      params += new_params
    end
  end
end
