module Bouncer
  module Outcome
    class Status < Base
      def serve
        if context.site.global_http_status
          case context.site.global_http_status
          when '301'
            guarded_redirect(context.site.global_new_url)
          when '410'
            [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
          end
        else
          case context.mapping.try(:http_status)
          when '301'
            guarded_redirect(context.mapping.new_url)
          when '410'
            [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
          else
            if request.path == '/410'
              [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
            else
              Bouncer::Rules.try(context, renderer) or
                [404, { 'Content-Type' => 'text/html' }, [renderer.render(context, 404)]]
            end
          end
        end
      end
    end
  end
end
