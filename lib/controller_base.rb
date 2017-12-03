require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash.rb'
require 'byebug'


class ControllerBase
  attr_reader :req, :res, :params, :flash

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params.merge(req.params)
    # store in a class variable so that every controller either protects from forgery or not.
    @@protect_from_forgery ||= false
  end
  
  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Already Built Response" if already_built_response?
    @already_built_response = url
    res.header["location"] = url
    res.status = 302
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    res['Content-Type'] = content_type
    raise "Already Built Response" if already_built_response?
    session.store_session(@res)
    @already_built_response = content
    res.write(@already_built_response)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    flash.store_flash(@res)
    controller_name = "#{self.class}".underscore
    template = "#{template_name}".underscore
    file_path = "../views/#{controller_name}/#{template}.html.erb"
    erb = ERB.new(File.read(file_path))
    render_content(erb.result(binding),'text/html')
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    check_authenticity_token unless req.request_method == "GET"
    self.send(name)
  # allows for default behavior =
    render(name) unless @already_built_response
  end

  def form_authenticity_token
    auth_token = authenticity_token
    res.set_cookie("authenticity_token", {
      path: "/",
      value: auth_token
      })
    auth_token
  end

  def authenticity_token
    @authenticity_token = req.cookies["authenticity_token"] ||
      @authenticity_token || SecureRandom::urlsafe_base64
  end

  protected

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  private

  def check_authenticity_token
    return if params["authenticity_token"] == authenticity_token
    raise "Invalid authenticity token"
  end

end
