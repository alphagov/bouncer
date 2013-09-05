module Bouncer
  module Outcome
    class GlobalHTTPStatus < Base
      def serve
        case context.site.global_http_status
        when '301'
          guarded_redirect(context.site.global_new_url)
        when '410'
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
        end
      end
    end
  end
end
