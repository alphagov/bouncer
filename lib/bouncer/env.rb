module Bouncer
  module Env
    def self.hostname
      "#{ENV['GOVUK_APP_NAME']}.#{ENV['GOVUK_APP_DOMAIN']}"
    end
  end
end
