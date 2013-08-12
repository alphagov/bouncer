module Bouncer
  module Outcome
    class Homepage < Base
      def serve
        guarded_redirect(context.site.homepage)
      end
    end
  end
end
