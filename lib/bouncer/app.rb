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
      elsif context.request.path == '/sitemap.xml'
        Outcome::Sitemap
      elsif context.request.path == '/robots.txt'
        Outcome::Robots
      elsif context.site.global_http_status
        Outcome::GlobalHTTPStatus
      elsif context.request.path == '' # after c14n, '' is equivalent to '/'
        Outcome::Homepage
      else
        Outcome::Status
      end

      outcome.new(context, @renderer).serve
    end
  end
end