module Bouncer
  ##
  # Canonicalize!ing middleware for Bouncer
  class C14nizer
    def initialize(app)
      @app = app
    end

    def call(env)
      BLURI(Rack::Request.new(env).url).tap do |bluri|
        # Note: this is recreated (and the queries repeated) in app.rb, though
        # it will use the canonicalised path/query.
        context = RequestContext.new(env)
        options = {}
        if context.host && context.host.site.query_params
          options[:allow_query] = context.host.site.query_params.split(":")
        end
        bluri.canonicalize!(options)
        env['PATH_INFO'] = bluri.path
        env['QUERY_STRING'] = bluri.query || ''
      end

      @app.call(env)
    end
  end
end
