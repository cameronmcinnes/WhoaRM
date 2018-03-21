require_relative 'lib/errors/not_saved.rb'
require_relative 'lib/validatable.rb'
require_relative 'lib/validator.rb'
require_relative 'lib/searchable.rb'
require_relative 'lib/associatable.rb'
require_relative 'lib/sql_object.rb'
require_relative 'lib/db_connection.rb'
require_relative 'demo.rb'

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

# load 'lib/errors/not_saved.rb'
# load 'lib/validatable.rb'
# load 'lib/validator.rb'
# load 'lib/searchable.rb'
# load 'lib/associatable.rb'
# load 'lib/sql_object.rb'
# load 'lib/db_connection.rb'
# load 'demo.rb'
