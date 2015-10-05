module Bouncer
  ##
  # Caching middleware for Bouncer
  class Cacher
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env).tap do |status, headers|
        # Double pipe equals (||=) assigns a value to a variable
        # only when that variable is nil or false.
        headers['Cache-Control'] ||= 'public, max-age=3600' unless status == 500
      end
    end
  end
end
