require_relative '../lib/interACT/sql_object'

class Comment < SQLObject
  belongs_to :todo

  def validate_save
    if self.body.length != 0 && self.todo_id
      self.save
      true
    else
      @errors = ["Comment needs a body"]
      false
    end
  end

  finalize!
end
