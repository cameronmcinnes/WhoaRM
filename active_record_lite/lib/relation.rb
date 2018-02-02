class Relation # < Array ??



  def initialize(params)
    @params = params
  end

  # how do i cause any attempt to use the relation object
  # to execute the query dictated by the params

  def inspect
    execute_query
  end

  def exectute_query


  end


  # makes stackable
  def add_params

  end

end
