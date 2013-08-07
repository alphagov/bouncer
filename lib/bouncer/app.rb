module Bouncer
  class App
    extend Forwardable

    def_delegators :@context, :host, :site, :mappings, :mapping, :organisation, :request

    def initialize()
      @renderer = StatusRenderer.new
    end

    def call(env)
      @context = RequestContext.new(env)

      if host.nil?
        case request.path
        when '/healthcheck'
          serve_healthcheck
        else
          serve_unrecognised_host
        end
      else
        case request.path
        when '' # same as / after c14n
          serve_homepage
        when '/sitemap.xml'
          serve_sitemap
        when '/robots.txt'
          serve_robots
        else
          serve_status
        end
      end
    end

    def serve_status
      case mapping.try(:http_status)
      when '301'
        [301, { 'Location' => mapping.new_url }, []]
      when '410'
        [410, { 'Content-Type' => 'text/html' }, [@renderer.render(@context, 410)]]
      else
        if request.path == '/410'
          [410, { 'Content-Type' => 'text/html' }, [@renderer.render(@context, 410)]]
        else
          [404, { 'Content-Type' => 'text/html' }, [@renderer.render(@context, 404)]]
        end
      end
    end

    def serve_sitemap
      sitemap = Nokogiri::XML::Builder.new do |xml|
        xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
          mappings.each do |mapping|
            url = URI.parse(mapping.path).tap do |uri|
              uri.scheme = 'http'
              uri.host = request.host
            end

            xml.url do
              xml.loc url
            end
          end
        end
      end

      [200, { 'Content-Type' => 'application/xml' }, [sitemap.to_xml]]
    end

    def serve_robots
      url = URI::HTTP.build(host: request.host, path: '/sitemap.xml')
      robots = <<eof
User-agent: *
Disallow:
Sitemap: #{url}
eof
      [200, { 'Content-Type' => 'text/plain' }, [robots]]
    end

    def serve_healthcheck
      [200, { 'Content-Type' => 'text/plain' }, ['OK']]
    end

    def serve_homepage
      [301, { 'Location' => site.homepage }, []]
    end

    def serve_unrecognised_host
      [404, {}, []]
    end
  end
end