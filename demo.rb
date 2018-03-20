require_relative 'lib/validatable.rb'
require_relative 'lib/sql_object'

class Contestant < SQLObject
  validates :lname, uniqueness: true, presence: true
  validates :fname, presence: true

  belongs_to :team
  finalize!
end

class Team < SQLObject
  has_many :contestants
  finalize!
end

# load 'lib/validatable.rb'
# load 'lib/validator.rb'
# load 'lib/searchable.rb'
# load 'lib/associatable.rb'
# load 'lib/sql_object.rb'
# load 'lib/db_connection.rb'
# load 'demo.rb'
