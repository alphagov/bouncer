module Bouncer
  module Outcome
    class BadRequest < Base
      def serve
        [400, {}, ["Bad Request"]]
      end
    end
  end
end
