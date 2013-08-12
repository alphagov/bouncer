module Bouncer
  module Outcome
    class Homepage < Base
      def serve
        if legal_redirect?(context.site.homepage)
          [301, { 'Location' => context.site.homepage }, []]
        else
          render_illegal_redirect(context.site.homepage)
        end
      end
    end
  end
end
