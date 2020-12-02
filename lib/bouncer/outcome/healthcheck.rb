module Bouncer
  module Outcome
    class Healthcheck < Base
      def serve
        GovukHealthcheck.rack_response(
          GovukHealthcheck::ActiveRecord,
        ).call
      end
    end
  end
end
