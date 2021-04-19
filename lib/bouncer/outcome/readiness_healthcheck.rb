module Bouncer
  module Outcome
    class ReadinessHealthcheck < Base
      def serve
        GovukHealthcheck.rack_response(
          GovukHealthcheck::ActiveRecord,
        ).call
      end
    end
  end
end
