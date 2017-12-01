require 'json'
require 'byebug'

class Flash
  attr_reader :now

# @now will be set to previous flash and @flash to an empty object.
  def initialize(req)
    @req = req
    deseralized_cookie = req.cookies["_rails_lite_app_flash"]
    @now = deseralized_cookie ? JSON.parse(deseralized_cookie) : {}
    @flash = {}
  end

# we will be setting cookies with only the newly added values, that way
# @flash will be available for one request cycle,
# swhereas @now will be available for only one.
  def store_flash(res)
    res.set_cookie("_rails_lite_app_flash", {
      path: "/",
      value: @flash.to_json
      })
  end

  def []=(key, val)
    @flash[key.to_s] = val
  end

  def [](key)
    @now[key.to_s] || @flash[key.to_s] ||
    @now[key.to_sym] || @flash[key.to_sym]
  end

end
