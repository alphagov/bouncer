require 'digest/sha1'
require 'erb'
require 'ostruct'
require 'rack/request'

require 'host'

class Bouncer
  def call(env)
    request = Rack::Request.new(env)
    host = Host.find_by host: request.host
    path_hash = Digest::SHA1.hexdigest(request.path)
    site = host.site if host
    mapping = site.mappings.find_by path_hash: path_hash if site

    case mapping.try(:http_status)
    when '301'
      [301, { 'Location' => mapping.new_url }, []]
    when '410'
      [410, {}, []]
    else
      template = File.read(File.expand_path('../../templates/404.erb', __FILE__))
      site_attributes = OpenStruct.new(attributes_for_site(site))
      html = ERB.new(template).result(site_attributes.instance_eval { binding })
      [404, {}, [html]]
    end
  end

  def attributes_for_site(site)
    organisation = site.try(:organisation)

    {
      homepage: organisation.try(:homepage),
      title: organisation.try(:title),
      css: organisation.try(:css)
    }
  end
end
