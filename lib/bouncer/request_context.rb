module Bouncer
  ##
  # Used to hold all the details about this request and how we might redirect it through mappings.
  # Serves as a context for any rendered template.
  class RequestContext
    attr_reader :request

    def initialize(canonicalized_request)
      @request = canonicalized_request
    end

    def host
      @_host ||= Host.find_by(host: @request.host)
    end

    def mapping
      # Reminder: the hash is always calculated on the canonicalize!d request
      mappings.find_by path_hash: Digest::SHA1.hexdigest(@request.fullpath)
    end

    def mappings
      site.mappings
    end

    def site
      host.site
    end

    def organisation
      site.organisation
    end

    def attributes_for_render
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

    def render_binding
      RenderingContext.new(attributes_for_render).render_binding
    end
  end
end
