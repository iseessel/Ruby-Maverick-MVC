# Rememeber to require controller base and all of your models!

require_relative '../lib/controller_base.rb'
require_relative '../models/all_models.rb'
require 'byebug'

class CommentsController < ControllerBase
  protect_from_forgery

  def create
    @comment = Comment.new(body: params["comment"]["body"])
    @comment.todo_id = params["todo_id"].to_i
    if @comment.validate_save
      redirect_to("/todos/#{params["todo_id"]}")
    else
      flash["comment-errors"] = ["Invalid Comment"]
      redirect_to("/todos/#{params["todo_id"]}")
    end
  end

  def destroy
    debugger
  end

end
