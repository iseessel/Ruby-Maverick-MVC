require 'rack'
require_relative '../lib/router'
require_relative '../lib/show_exceptions'
require_relative '../lib/static'
require_relative '../controllers/all_controllers'

router = Router.new
router.draw do
  get(Regexp.new("^/todos$"), TodosController, :index)
  get(Regexp.new("^/todos/new$"), TodosController, :new)
  get(Regexp.new("^/todos/(?<todo_id>\\d+)$"), TodosController, :show)
  post(Regexp.new("^/todos$"), TodosController, :create)
  post(Regexp.new("^/todos/(?<todo_id>\\d+)/comments$"), CommentsController, :create)
  delete(Regexp.new("^/comments/(?<comment_id>\\d+)$"), CommentsController, :destroy)
  delete(Regexp.new("^/todos/(?<todo_id>\\d+)$"), TodosController, :destroy)
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req,res)
  res.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  use Static
  run app
end.to_app

Rack::Server.start(
  app: app,
  Port: 3000
)
