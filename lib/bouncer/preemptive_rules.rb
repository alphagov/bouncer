module Bouncer
  ##
  # Rules to try before mappings because they are too important to let mappings
  # be used. This is a particular concern with mappings created automatically.
  class PreemptiveRules
    FLOODS_PATHS = [
      '/homeandleisure/floods/cy/34678.aspx',
      '/homeandleisure/floods/34678.aspx',
    ]

    def self.redirect(location)
      [301, { 'Location' => location }, []]
    end

    def self.try(context, renderer)
      request = context.request
      if request.host == 'www.environment-agency.gov.uk' && FLOODS_PATHS.include?(request.path)
        redirect("http://flood.environment-agency.gov.uk#{request.non_canonicalised_fullpath}")
      end
    end
  end
end
