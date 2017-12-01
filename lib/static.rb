require 'byebug'

class Static

  MIME_TYPES = {
  '.txt' => 'text/plain',
  '.jpg' => 'image/jpeg',
  '.zip' => 'application/zip'
}

  def initialize(app)
    @app = app
  end

  # If it is an allowed file find the file, otherwise continue to our main app
  # (which will go to our router).

  def call(env)
    res = Rack::Response.new
    req = Rack::Request.new(env)
    file_name = file_name(req)
    if allowed_file?(req)
      render_file(file_name, res)
    else
      return @app.call(env)
    end
    res
  end

  private

  def render_file(file_name, res)
    if File.exists?(file_name)
      file = File.read(file_name)
      res["Content-type"] = MIME_TYPES[File.extname(file_name)]
      res.status = 200
      res.write(file)
    else
      res.status = 404
      res.write("File not found")
    end
  end

  def file_name(req)
    current_directory = File.dirname(__FILE__)
    File.join(current_directory,'..',req.path)
  end

  #ensures that users are only allowed to use the allowed file
  def allowed_file?(req)
    req.path.start_with?("/public/")
  end

end
