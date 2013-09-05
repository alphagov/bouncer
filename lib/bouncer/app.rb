module Bouncer
  class App
    def initialize()
      @renderer = StatusRenderer.new
    end

    def call(env)
      context = RequestContext.new(CanonicalizedRequest.new(env))

      outcome = if context.host.nil?
        case context.request.path
        when '/healthcheck' then Outcome::Healthcheck
        else
          Outcome::UnrecognisedHost
        end
      elsif ['/404', '/410'].include?(context.request.path)
        Outcome::TestThe4xxPages
      elsif context.site.global_http_status
        Outcome::GlobalHTTPStatus
      else
        case context.request.path
        when ''             then Outcome::Homepage # after c14n, '' is equivalent to '/'
        when '/sitemap.xml' then Outcome::Sitemap
        when '/robots.txt'  then Outcome::Robots
        else
          Outcome::Status
        end
      end

      outcome.new(context, @renderer).serve
    end
  end
end