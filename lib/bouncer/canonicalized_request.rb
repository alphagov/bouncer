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

    def non_canonicalised_path
      @request.path
    end

    def path
      bluri.path
    end

    def non_canonicalised_query
      @request.query_string
    end

    def query
      bluri.query
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
      # Therefore, to canonicalise it, we need to reverse that transformation.
      #
      # We need to downcase because PostgreSQL is case-sensitive when querying,
      # and canonicalization doesn't handle this for the host.
      @request.host.sub(/^aka-/, '').sub(/^aka\./, 'www.').downcase
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
      host_record = Host.find_by(hostname: self.host)
      # It would be nice to reuse this variable in RequestContext to avoid
      # duplicate queries, though the ActiveRecord query cache is now
      # preventing the repeat DB round trip.
      if host_record && host_record.site.query_params
        host_record.site.query_params.split(":")
      else
        []
      end
    end
  end
end
