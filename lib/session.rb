require 'json'

class Session

  def initialize(req)
    deseralized_cookie = req.cookies["_rails_lite_app"]
    if deseralized_cookie
      @cookie = JSON.parse(deseralized_cookie)
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key.to_sym] || @cookie[key.to_s]
  end

  def []=(key, val)
    @cookie[key.to_sym] = val
  end

  def store_session(res)
    res.set_cookie("_rails_lite_app", {
      path: "/",
      value: JSON.generate(@cookie)
      })
  end
end
