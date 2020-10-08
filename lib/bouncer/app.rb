module Bouncer
  class App
    def initialize
      @renderer = StatusRenderer.new
    end

    def call(env)
      context = RequestContext.new(CanonicalizedRequest.new(env))

      outcome = if context.host.nil? && context.request.path == "/healthcheck"
                  Outcome::Healthcheck
                elsif context.host.nil?
                  Outcome::UnrecognisedHost
                elsif ["/404", "/410"].include?(context.request.path)
                  Outcome::TestThe4xxPages
                elsif context.host.hostname == "www.direct.gov.uk" && context.request.path == "/__canary__"
                  Outcome::Canary
                elsif context.request.path == "/sitemap.xml"
                  Outcome::Sitemap
                elsif context.request.path == "/robots.txt"
                  Outcome::Robots
                elsif context.site.global_type
                  Outcome::GlobalType
                elsif context.request.path == "" # after c14n, '' is equivalent to '/'
                  Outcome::Homepage
                else
                  Outcome::Status
                end

      outcome.new(context, @renderer).serve
    end
  end
end
