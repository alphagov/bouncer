module Bouncer
  ##
  # Used to hold all the details about this request and how we might redirect it through mappings.
  # Serves as a context for any rendered template.
  class RequestContext
    attr_reader :request

    def initialize(canonicalized_request)
      @request = canonicalized_request
    end

    def valid?
      @request.valid?
    end

    def host
      @host ||= Host.find_by(hostname: @request.host)
    end

    def mapping
      # Reminder: the request's fullpath is canonical
      mappings.find_by path: @request.fullpath
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
      {
        homepage: site.homepage,
        title: site.homepage_title || organisation.title,
        css: organisation.css,
        furl: site.homepage_furl,
        host: host.hostname,
        suggested_url: mapping.try(:suggested_url),
        archive_url: mapping.try(:archive_url) || default_archive_url,
        alternative_archive_text:,
      }
    end

    def default_archive_url
      tna_timestamp = site.tna_timestamp.try(:strftime, "%Y%m%d%H%M%S")
      "https://webarchive.nationalarchives.gov.uk/#{tna_timestamp}/http://#{host.hostname}#{request.non_canonicalised_fullpath}"
    end

    def alternative_archive_text
      retun unless site.alternative_archive_text

      Kramdown::Document.new(site.alternative_archive_text).to_html
    end
  end
end
