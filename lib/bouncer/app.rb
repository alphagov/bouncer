class Bouncer::App
  def initialize()
    @renderer = StatusRenderer.new
  end

  def call(env)
    request = Rack::Request.new(env)

    host = Host.find_by host: request.host
    site = host.site if host
    mappings = site.mappings if site

    case request.path
    when '' # same as / after c14n
      serve_homepage(site)
    when '/sitemap.xml'
      serve_sitemap(request, mappings)
    when '/robots.txt'
      serve_robots(request)
    else
      serve_status(host, mappings, request)
    end
  end

  def serve_status(host, mappings, request)
    mapping = mappings.find_by path_hash: Digest::SHA1.hexdigest(request.fullpath) if mappings
    context = RenderingContext.new(context_attributes_from_request(host, request, mapping))

    case mapping.try(:http_status)
    when '301'
      [301, { 'Location' => mapping.new_url }, []]
    when '410'
      [410, { 'Content-Type' => 'text/html' }, [@renderer.render(context, 410)]]
    else
      if request.path == '/410'
        [410, { 'Content-Type' => 'text/html' }, [@renderer.render(context, 410)]]
      else
        [404, { 'Content-Type' => 'text/html' }, [@renderer.render(context, 404)]]
      end
    end
  end

  def serve_sitemap(request, mappings)
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

  def serve_robots(request)
    url = URI::HTTP.build(host: request.host, path: '/sitemap.xml')
    robots = <<eof
User-agent: *
Disallow:
Sitemap: #{url}
eof
    [200, { 'Content-Type' => 'text/plain' }, [robots]]
  end

  def serve_homepage(site)
    [301, { 'Location' => site.homepage }, []]
  end

  def context_attributes_from_request(host, request, mapping)
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
