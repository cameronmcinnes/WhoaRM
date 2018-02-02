require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end

# make where lazy and stackable

# modify to create relation object with given params

# add conditional so if #where is called with a relation object as
# the receiver we add to that relaion object instead of creating a new one
# stackable

# leave parsing to #where
