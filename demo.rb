require_relative 'lib/errors/not_saved.rb'
require_relative 'lib/sql_object.rb'
require_relative 'lib/validatable.rb'
require_relative 'lib/validator.rb'
require_relative 'lib/searchable.rb'
require_relative 'lib/associatable.rb'
require_relative 'lib/db_connection.rb'
require_relative 'demo.rb'


class Team < SQLObject
  has_many :members, class_name: 'Contestant'
  finalize!
end

class Contestant < SQLObject
  validates :lname, uniqueness: true, presence: true
  validates :fname, presence: true

  belongs_to :team
  finalize!
end

class Obstacle < SQLObject
  validates :name, presence: true, uniqueness: true

  belongs_to :contestant
  has_one_through :team, :contestant, :team
  finalize!
end
