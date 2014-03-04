module Bouncer
  ##
  # Rules to try before mappings because they are too important to let mappings
  # be used. This is a particular concern with mappings created automatically.
  class PreemptiveRules
    FLOODS_PATHS = [
      '/homeandleisure/floods/cy/34678.aspx',
      '/homeandleisure/floods/34678.aspx',
      '/homeandleisure/floods/34681.aspx',
      '/homeandleisure/floods/cy/34681.aspx',
      '/homeandleisure/floods/147053.aspx',
      '/homeandleisure/floods/cy/147053.aspx',
      '/homeandleisure/floods/riverlevels/notactive.aspx',
      '/homeandleisure/floods/riverlevels/cy/notactive.aspx',
      '/homeandleisure/floods/riverlevels/riverstation.aspx',
      '/homeandleisure/floods/riverlevels/cy/riverstation.aspx',
    ]

    FLOODS_REGEXES = [
      %r{^/homeandleisure/floods/riverlevels/\d+\.aspx$},
      %r{^/homeandleisure/floods/riverlevels/cy/\d+\.aspx$},
    ]

    def self.redirect(location)
      [301, { 'Location' => location }, []]
    end

    def self.try(context, renderer)
      request = context.request
      if request.host == 'www.environment-agency.gov.uk'
        if FLOODS_PATHS.include?(request.path) || FLOODS_REGEXES.any? { |regex| regex =~ request.path }
          redirect("http://flood.environment-agency.gov.uk#{request.non_canonicalised_fullpath}")
        end
      end
    end
  end
end
