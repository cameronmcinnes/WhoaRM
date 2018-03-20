# require_relative 'db_connection'
require_relative 'sql_object'
require_relative 'relation'

module Searchable
  # made lazy and stackable by implementing relation class
  # relation instances hold given parameters

  def where(params)
    Relation.new(self, params)
  end
end
