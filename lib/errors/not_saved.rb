class RecordNotSaved < StandardError
  attr_reader :validation_errors

  def initialize(validation_errors)
    @validation_errors = validation_errors
  end
end
