module Bouncer
  module Outcome
    class Healthcheck < Base
      def serve
        [200, { 'Content-Type' => 'text/plain' }, ['OK']]
      end
    end
  end
end
