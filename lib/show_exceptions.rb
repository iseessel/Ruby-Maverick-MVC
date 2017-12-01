require 'erb'
require 'byebug'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue Exception => e
      render_exception(e)
    end
  end

  private

  # Read our error rendering template bound to this context, so we have access
  # to @message and @backtrace. 
  def render_exception(e)
    @message = e.message
    @backtrace = e.backtrace
    response_erb = ERB.new(File.read("lib/templates/rescue.html.erb"))
    response_text = response_erb.result(binding)
    response = ['500', {'Content-type' => 'text/html'}, [response_text]]
  end

end
