require 'digest/sha1'
require 'erb'
require 'ostruct'
require 'rack/request'

require 'host'

class Bouncer
  def call(env)
    request = Rack::Request.new(env)
    host = Host.find_by host: request.host
    path_hash = Digest::SHA1.hexdigest(request.fullpath)
    site = host.site if host
    mapping = site.mappings.find_by path_hash: path_hash if site

    case mapping.try(:http_status)
    when '301'
      [301, { 'Location' => mapping.new_url }, []]
    when '410'
      template = File.read(File.expand_path('../../templates/410.erb', __FILE__))
      template_context = template_context_for_host_and_request_and_mapping(host, request, mapping)
      html = ERB.new(template).result(template_context)
      [410, { 'Content-Type' => 'text/html' }, [html]]
    else
      template = File.read(File.expand_path('../../templates/404.erb', __FILE__))
      template_context = template_context_for_host_and_request_and_mapping(host, request, mapping)
      html = ERB.new(template).result(template_context)
      [404, { 'Content-Type' => 'text/html' }, [html]]
    end
  end

  def template_context_for_host_and_request_and_mapping(host, request, mapping)
    site = host.try(:site)
    organisation = site.try(:organisation)
    suggested_url = mapping.try(:suggested_url)

    attributes = {
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

    template_context_from_hash(attributes)
  end

  def template_context_from_hash(hash)
    OpenStruct.new(hash).instance_eval { binding }
  end
end
