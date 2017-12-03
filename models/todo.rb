require_relative '../lib/interACT/sql_object'

class Todo < SQLObject
  attr_reader :errors

  has_many :comments
  
  def validate_save
    if self.name.length != 0
      self.save
      true
    else
      @errors = ["Todo needs a name"]
      false
    end
  end

  finalize!
end
