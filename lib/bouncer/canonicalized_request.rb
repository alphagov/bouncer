module Bouncer
  class CanonicalizedRequest
    def initialize(env_or_request)
      @request = env_or_request.is_a?(Rack::Request) ? env_or_request : Rack::Request.new(env_or_request)
    end

    def fullpath
      if bluri.query.nil? || bluri.query.empty?
        bluri.path
      else
        "#{bluri.path}?#{bluri.query}"
      end
    end

    def path
      bluri.path
    end

    def host
      @request.host.sub(/^aka-/, '')
    end

  private
    def bluri
      @_fullpath ||= begin
        bluri = BLURI(@request.url)
        bluri.canonicalize!(allow_query: significant_query_params)
      end
    end

    def significant_query_params
      # We must use the canonicalized_host, not @request.host
      host_record = Host.find_by(host: self.host)
      # It would be nice to reuse this variable in RequestContext to avoid
      # duplicate queries. If we had ActionController's query cache this would
      # happen by magic. It seems messy to expose it directly.
      if host_record && host_record.site.query_params
        host_record.site.query_params.split(":")
      else
        []
      end
    end
  end
end
