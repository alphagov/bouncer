module Bouncer
  ##
  # Caching middleware for Bouncer
  class Cacher
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env).tap do |response|
        response [1]['Cache-Control'] = "public, max-age=3600" unless response[1]['Cache-Control']
      end
    end
  end
end
