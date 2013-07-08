require 'digest/sha1'
require 'rack/request'

class Bouncer
  def call(env)
    request = Rack::Request.new(env)
    host = Host.find_by host: request.host
    path_hash = Digest::SHA1.hexdigest(request.path)
    mapping = host.site.mappings.find_by path_hash: path_hash

    case mapping.http_status
    when '301'
      [301, { 'Location' => mapping.new_url }, []]
    when '410'
      [410, {}, []]
    end
  end
end
