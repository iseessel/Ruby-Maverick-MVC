require_relative '../lib/controller_base.rb'
require_relative '../models/all_models.rb'
require 'byebug'

class TodosController < ControllerBase
  protect_from_forgery

  def index
    @todos = Todo.all
    render :index
  end

  def new
    render :new
  end

  def create
    @todo = Todo.new(name: params["todo"]["body"])
    if @todo.validate_save
      redirect_to("/todos/#{@todo.id}")
    else
      flash.now[:errors] = @todo.errors
      render :new
    end
  end

  def show
    @todo = Todo.find(params["todo_id"])
    if @todo
      @comments = @todo.comments
      render :show
    else
      flash[:errors] = ["Todo Cannot be found"]
      redirect_to("/todos")
    end
  end

  def destroy
  end

end
