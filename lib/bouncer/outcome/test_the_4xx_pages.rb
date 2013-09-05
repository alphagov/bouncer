module Bouncer
  module Outcome
    # It's useful to get a guaranteed 404 or 410 page for demonstration and
    # testing.
    class TestThe4xxPages < Base
      def serve
        case context.request.path
        when '/404'
          [404, { 'Content-Type' => 'text/html' }, [renderer.render(context, 404)]]
        when '/410'
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
        end
      end
    end
  end
end
