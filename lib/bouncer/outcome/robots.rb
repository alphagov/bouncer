module Bouncer
  module Outcome
    class Robots < Base
      def serve
        url = URI::HTTP.build(host: context.request.host, path: "/sitemap.xml")
        robots = <<~ROBOTS
          User-agent: *
          Disallow:
          Sitemap: #{url}
        ROBOTS
        [200, { "Content-Type" => "text/plain" }, [robots]]
      end
    end
  end
end
