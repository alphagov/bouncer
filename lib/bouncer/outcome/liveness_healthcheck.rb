module Bouncer
  module Outcome
    class LivenessHealthcheck < Base
      def serve
        [200, {}, %w[OK]]
      end
    end
  end
end
