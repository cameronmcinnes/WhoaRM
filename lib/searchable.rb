require_relative 'sql_object'
require_relative 'relation'

module Searchable
  def where(params)
    Relation.new(self, params)
  end
end
