module Bouncer
  ##
  # Rules to try before mappings because they are too important to let mappings
  # be used. This is a particular concern with mappings created automatically.
  class PreemptiveRules
    def self.redirect(location)
      [301, { 'Location' => location }, []]
    end

    def self.try(context, renderer)
      request = context.request
      if request.host == 'www.environment-agency.gov.uk' && request.path == '/homeandleisure/floods/34678.aspx'
        redirect("http://flood.environment-agency.gov.uk#{request.non_canonicalised_fullpath}")
      end
    end
  end
end
