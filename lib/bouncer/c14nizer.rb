module Bouncer
  ##
  # Canonicalize!ing middleware for Bouncer
  class C14nizer
    def initialize(app)
      @app = app
    end

    def call(env)
      BLURI(Rack::Request.new(env).url).tap do |bluri|
        bluri.canonicalize!(allow_query: :all)
        env['PATH_INFO'] = bluri.path
        env['QUERY_STRING'] = bluri.query || ''
      end

      @app.call(env)
    end
  end
end
