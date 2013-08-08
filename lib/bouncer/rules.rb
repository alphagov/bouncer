module Bouncer
  ##
  # Regex rules to try after mappings but just before we 404
  class Rules
    def self.try(request, renderer)
      if request.host == 'www.dfid.gov.uk' && request.path =~ %r{^/r4d/(.*)$}
        [301, { 'Location' => "http://r4d.dfid.gov.uk/#{$1}" }, []]
      elsif request.host == 'www.dh.gov.uk' && request.path =~ %r{/dh_digitalassets/}
        [410, { 'Content-Type' => 'text/html' }, [renderer.render(RequestContext.new(request), '410')]]
      elsif request.host == 'www.direct.gov.uk' && request.path =~ %r{/(en/)?AdvancedSearch}i
        [301, { 'Location' => 'https://www.gov.uk/search' }, []]
      elsif request.host == 'campaigns.direct.gov.uk' && request.path =~ %r{/firekills}
        [301, { 'Location' => 'https://www.gov.uk/firekills' }, []]
      elsif request.host == 'www.number10.gov.uk' && request.path =~ %r{^/news/?([_0-9a-zA-Z-]+)?/([0-9]+)/([0-9]+)/(.*)-([0-9]+)$}
        [301, { 'Location' => "http://www.number10.gov.uk/news/#{$4}" }, []]
      elsif request.host == 'cdn.hm-treasury.gov.uk' && request.path =~ %r{^/d/(.*)$}
        [301, { 'Location' => "http://www.hm-treasury.gov.uk/#{$1}" }, []]
      end
    end
  end
end
