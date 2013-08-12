module Bouncer
  class App
    def initialize()
      @renderer = StatusRenderer.new
    end

    def call(env)
      context = RequestContext.new(env)

      outcome = if context.host.nil?
        case context.request.path
        when '/healthcheck' then Outcome::Healthcheck
        else
          Outcome::UnrecognisedHost
        end
      else
        case context.request.path
        when ''             then Outcome::Homepage # after c14n, '' is equivalent to '/'
        when '/sitemap.xml' then Outcome::Sitemap
        when '/robots.txt'  then Outcome::Robots
        else
          Outcome::Status
        end
      end

      response = outcome.new(context, @renderer).serve
      # Set a blanket 1 hour Cache-Control value unless one is set
      response [1]['Cache-Control'] = "public, max-age=3600"# unless response[1]['Cache-Control']
      response
    end
  end
end