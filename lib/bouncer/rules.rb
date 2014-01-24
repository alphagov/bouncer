module Bouncer
  ##
  # Regex rules to try after mappings but just before we 404
  class Rules
    def self.try(context, renderer)
      request = context.request
      if request.host == 'www.dfid.gov.uk' && request.path =~ %r{^/r4d/(.*)$}
        new_path = request.non_canonicalised_path.gsub(%r{^/r4d/}, "")
        [301, { 'Location' => "http://r4d.dfid.gov.uk/#{new_path}" }, []]
      elsif request.host == 'www.dh.gov.uk' && request.path =~ %r{/dh_digitalassets/}
        [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, '410')]]
      elsif request.host == 'www.direct.gov.uk' && request.path =~ %r{/(en/)?AdvancedSearch}i
        [301, { 'Location' => 'https://www.gov.uk/search' }, []]
      elsif request.host == 'campaigns.direct.gov.uk' && request.path =~ %r{/firekills}
        [301, { 'Location' => 'https://www.gov.uk/firekills' }, []]
      elsif request.host == 'www.number10.gov.uk' && request.path =~ %r{^/news/?([_0-9a-zA-Z-]+)?/([0-9]+)/([0-9]+)/(.*)-([0-9]+)$}
        [301, { 'Location' => "http://www.number10.gov.uk/news/#{$4}" }, []]
      elsif request.host == 'cdn.hm-treasury.gov.uk' && request.path =~ %r{^/(.*)$}
        [301, { 'Location' => "http://www.hm-treasury.gov.uk/#{$1}" }, []]
      elsif request.host == 'digital.cabinetoffice.gov.uk' && request.path =~ %r{^/(.*)$}
        [301, { 'Location' => "https://gds.blog.gov.uk/#{$1}" }, []]
      elsif request.host == 'www.dft.gov.uk'
      	if request.path =~ %r{^/actonco2/?(.*)$}
        	[301, { 'Location' => "http://actonco2.direct.gov.uk/#{$1}" }, []]
        elsif request.path =~ %r{^/think/[dont]?drugdrive(.*)$}
        	[301, { 'Location' => "http://drugdrive.direct.gov.uk/#{$1}" }, []]
        elsif request.path =~ %r{^/thinkmotorcycleacademy(.*)$}
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, '410')]]
        elsif request.path =~ %r{^/think/(.*)$}
        	[301, { 'Location' => "http://think.direct.gov.uk/#{$1}" }, []]
        elsif request.path =~ %r{^/transportforyou/roadsafety(.*)$}
        	[301, { 'Location' => "http://think.direct.gov.uk/#{$1}" }, []]
        elsif request.path =~ %r{^/transportforyou/tfytalesoftheroad(.*)$}
        	[301, { 'Location' => "http://think.direct.gov.uk/#{$1}" }, []]
        elsif request.path =~ %r{^/press/releases/pressarchive(.*)$}
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, '410')]]
        elsif request.path =~ %r{^/press/releases/sra(.*)$}
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, '410')]]
        elsif request.path =~ %r{^/rhc(.*)$}
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, '410')]]
        elsif request.path =~ %r{^/hmep(.*)$}
        	[301, { 'Location' => "http://www.highwaysefficiency.org.uk" }, []]
        elsif request.path =~ %r{^/matrix/?(.*)$}
        	[301, { 'Location' => "http://www.dft.gov.uk/traffic-counts/#{$1}" }, []]
        elsif request.path =~ %r{^/dsa/atozdtcinfo(.*)$}
        	[301, { 'Location' => "http://www.dft.gov.uk/fyn/practical.php" }, []]
        end
      end
    end
  end
end
