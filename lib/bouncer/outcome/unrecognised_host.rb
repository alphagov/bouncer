module Bouncer
  module Outcome
    class UnrecognisedHost < Base
      def serve
        [404, {}, []]
      end
    end
  end
end