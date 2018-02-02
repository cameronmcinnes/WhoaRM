class Relation < Array

# use this in order to test whether or not a method called on relation
# is an array method, if it is, execute the query
  
  def self.my_methods
    Array.instance_methods - self.instance_methods
  end

  def initialize(params)
    @params = params
  end

  # how do i cause any attempt to use the relation object
  # to execute the query dictated by the params

  # anytime you interact w a relation object you have to alter
  # some aspect of the class

  def inspect
    execute_query

    parse # => return object
  end

  def exectute_query


  end


  # makes stackable
  def add_params

  end

end
