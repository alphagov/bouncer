module Bouncer
  ##
  # Regex rules to try after mappings but just before we 404
  class FallbackRules
    def self.redirect(location)
      [301, { 'Location' => location }, []]
    end

    def self.gone(context, renderer)
      [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, '410')]]
    end

    def self.try(context, renderer)
      request = context.request

      case request.host
      when 'www.dfid.gov.uk', 'dfid.gov.uk'
        if request.path =~ %r{^/r4d/(.*)$}
          new_path = request.non_canonicalised_path.gsub(%r{^/r4d/}, '')
          redirect("http://r4d.dfid.gov.uk/#{new_path}")
        end
      when 'www.dh.gov.uk', 'dh.gov.uk'
        gone(context, renderer) if request.path =~ %r{/dh_digitalassets/}
      when 'www.direct.gov.uk', 'direct.gov.uk'
        redirect('https://www.gov.uk/search') if request.path =~ %r{/(en/)?AdvancedSearch}i
      when 'campaigns.direct.gov.uk'
        redirect('https://www.gov.uk/firekills') if request.path =~ %r{/firekills}
      when 'www.number10.gov.uk', 'number10.gov.uk'
        redirect("http://www.number10.gov.uk/news/#{$4}") if
          request.path =~ %r{^/news/?([_0-9a-zA-Z-]+)?/([0-9]+)/([0-9]+)/(.*)-([0-9]+)$}
      when 'digital.cabinetoffice.gov.uk'
        redirect("https://gds.blog.gov.uk/#{$1}") if request.path =~ %r{^/(.*)$}
      when 'govstore.service.gov.uk'
        case request.path
        when %r{^/cloudstore/([_0-9a-zA-Z-]+)$}
          redirect("http://www.digitalmarketplace.service.gov.uk/service/#{$1}")
        when %r{^/cloudstore(/[ips]aas|/scs)(/[_0-9a-zA-Z-]+){0,2}/([_0-9a-zA-Z-]+)$}
          redirect("http://www.digitalmarketplace.service.gov.uk/service/#{$3}")
        else
          redirect('https://www.gov.uk/digital-marketplace')
        end
      end
    end
  end
end
