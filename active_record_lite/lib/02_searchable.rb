require_relative 'db_connection'
require_relative '01_sql_object'
require_relative 'relation'

module Searchable

  # made lazy and stackable by implementing relation class
  # relation instances hold given parameters

  def where(params)
    Relation.new(self, params)
  end
end

class SQLObject
  extend Searchable
end

# old code that passes all where specs (two specs fail with new
# implementation because they expect an empty array and get a relation)

#where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
#
# results = DBConnection.execute(<<-SQL, *params.values)
#   SELECT
#     *
#   FROM
#     #{table_name}
#   WHERE
#     #{where_line}
# SQL
#
# parse_all(results)
