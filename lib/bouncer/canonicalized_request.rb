module Bouncer
  class CanonicalizedRequest
    def initialize(env_or_request)
      @request = Rack::Request.new(env_or_request)
    end

    def non_canonicalised_fullpath
      @request.fullpath
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
      # This behaviour is based on a reading of
      # https://github.com/alphagov/redirector/blob/b7713cf5bb175a4a31b47e4aa191399c294da11b/templates/nginx.erb#L16
      #
      # When deciding on aka hostnames to use, we use the following logic:
      #
      #   If it does not start with www., we add aka- to the hostname:
      #     foo.com => aka-foo.com
      #
      #   If it starts with www. we replace www with aka.:
      #     www.bar.com => aka.bar.com
      #
      # Therefore, to canonicalise it, we need to reverse that transformation:
      @request.host.sub(/^aka-/, '').sub(/^aka\./, 'www.')
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
