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
      if request.host == 'www.environment-agency.gov.uk'
        if request.non_canonicalised_fullpath =~ %r{^/homeandleisure/floods/riverlevels(/.*)?$}i
          redirect("http://apps.environment-agency.gov.uk/river-and-sea-levels#{$1}")
        elsif request.non_canonicalised_fullpath =~ %r{^/homeandleisure/floods/((cy/)?(34678|34681|147053)\.aspx(\?.*)?)$}i
          redirect("http://apps.environment-agency.gov.uk/flood/#{$1}")
        end
      end
    end
  end
end
