module Bouncer
  module Outcome
    class Homepage < Base
      def serve
        [301, { 'Location' => context.site.homepage }, []]
      end
    end
  end
end
