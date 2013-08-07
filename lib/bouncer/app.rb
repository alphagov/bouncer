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
        else Outcome::UnrecognisedHost
        end
      else
        case context.request.path
        when '' then              Outcome::Homepage
        when '/sitemap.xml' then  Outcome::Sitemap
        when '/robots.txt' then   Outcome::Robots
        else
          Outcome::Status
        end
      end

      outcome.new(context, renderer: @renderer).serve
    end
  end
end