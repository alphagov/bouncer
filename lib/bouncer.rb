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
    mapping = host.site.mappings.find_by path_hash: path_hash if host

    case mapping.try(:http_status)
    when '301'
      [301, { 'Location' => mapping.new_url }, []]
    when '410'
      [410, {}, []]
    else
      template = File.read(File.expand_path('../../templates/404.erb', __FILE__))
      site_attributes = OpenStruct.new homepage: 'http://www.gov.uk/government/organisations/ministry-of-truth', title: 'Ministry of Truth'
      html = ERB.new(template).result(site_attributes.instance_eval { binding })
      [404, {}, [html]]
    end
  end
end
