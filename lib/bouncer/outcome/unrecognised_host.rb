module Bouncer
  module Outcome
    class UnrecognisedHost < Base
      def serve
        [404, {}, ["This host is not configured in Transition"]]
      end
    end
  end
end
