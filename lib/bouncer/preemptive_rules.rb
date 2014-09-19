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

      case request.host
      when 'www.environment-agency.gov.uk'
        case request.non_canonicalised_fullpath
        when %r{^/homeandleisure/floods/riverlevels(/.*)?$}i
          redirect("http://apps.environment-agency.gov.uk/river-and-sea-levels#{$1}")
        when %r{^/homeandleisure/floods/((cy/)?(34678|34681|147053)\.aspx(\?.*)?)$}i
          redirect("http://apps.environment-agency.gov.uk/flood/#{$1}")
        end

      when 'www.businesslink.gov.uk'
        case request.non_canonicalised_fullpath
        when %r{^(.*site=230.*)$}i
          redirect("http://business.wales.gov.uk#{$1}")
        when %r{^(.*site=191.*)$}i
          redirect("http://www.nibusinessinfo.co.uk#{$1}")
        end

      when 'www.mcga.gov.uk'
        case request.non_canonicalised_fullpath
        when %r{^/c4mca/(.*)$}
          redirect("http://www.dft.gov.uk/mca/#{$1}")
        when %r{^/mca/(.*)$}
          redirect("http://www.dft.gov.uk/mca/#{$1}")
        when %r{^/(.*)$}
          redirect("http://www.dft.gov.uk/mca/#{$1}")
        end
      end

    end
  end
end
