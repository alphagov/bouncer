require 'digest/sha1'
require 'erb'
require 'nokogiri'
require 'ostruct'
require 'rack/request'
require 'uri'
require 'rendering_context'
require 'status_renderer'

require 'host'

class Bouncer
  def initialize()
    @renderer = StatusRenderer.new
  end

  def call(env)
    request = Rack::Request.new(env)

    host = Host.find_by host: request.host
    site = host.site if host

    mappings = site.mappings if site

    if request.path == '/sitemap.xml'
      sitemap = Nokogiri::XML::Builder.new do |xml|
        xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
          mappings.each do |mapping|
            url =
                URI.parse(mapping.path).tap do |uri|
                  uri.scheme = 'http'
                  uri.host = request.host
                end

            xml.url do
              xml.loc url
            end
          end
        end
      end

      [200, {'Content-Type' => 'application/xml'}, [sitemap.to_xml]]
    elsif request.path == '/robots.txt'
      url = URI::HTTP.build(host: request.host, path: '/sitemap.xml')
      robots = <<eof
User-agent: *
Disallow:
Sitemap: #{url}
eof
      [200, {'Content-Type' => 'text/plain'}, [robots]]
    else
      mapping = mappings.find_by path_hash: Digest::SHA1.hexdigest(request.fullpath) if mappings
      context = RenderingContext.new(context_from_request_details(host, request, mapping))

      case mapping.try(:http_status)
        when '301'
          [301, {'Location' => mapping.new_url}, []]
        when '410'
          [410, {'Content-Type' => 'text/html'}, [@renderer.render(context, 410)]]
        else
          if request.path == '/410'
            [410, {'Content-Type' => 'text/html'}, [@renderer.render(context, 410)]]
          else
            [404, {'Content-Type' => 'text/html'}, [@renderer.render(context, 404)]]
          end
      end
    end
  end

  def context_from_request_details(host, request, mapping)
    site = host.try(:site)
    organisation = site.try(:organisation)
    suggested_url = mapping.try(:suggested_url)

    {
        homepage: organisation.try(:homepage),
        title: organisation.try(:title),
        css: organisation.try(:css),
        furl: organisation.try(:furl),
        host: host.try(:host),
        tna_timestamp: site.try(:tna_timestamp).try(:strftime, '%Y%m%d%H%M%S'),
        request_uri: request.fullpath,
        suggested_link: suggested_url.nil? ? nil : %Q{<a href="#{suggested_url}">#{suggested_url.gsub(%r{\Ahttps?://|/\z}, '')}</a>},
        archive_url: mapping.try(:archive_url)
    }
  end
end