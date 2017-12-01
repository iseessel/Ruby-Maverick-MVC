class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    match_path = !!(@pattern =~ req.path)
    match_method = req.request_method == @http_method.to_s.upcase
    match_path && match_method
  end

  # instantiate controller and call controller action
  def run(req, res)
    route_params = {}
    match_data = Regexp.new(@pattern).match(req.path)
    match_data.names.each do |key|
      route_params[key] = match_data[key]
    end
    @controller = @controller_class.new(req, res, route_params)
    @controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance, syntatic sugar.
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make methods that when called creates a route.
  [:get, :post, :put, :delete, :patch, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.find{ |route| route.matches?(req) }
  end

  def run(req, res)
    matching_route = match(req)
    if matching_route
      matching_route.run(req,res)
    else
      res.status = 404
    end
  end

end
