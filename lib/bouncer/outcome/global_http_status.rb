module Bouncer
  module Outcome
    class GlobalHTTPStatus < Base
      def serve
        case context.site.global_http_status
        when '301'
          new_url = if context.site.global_redirect_append_path
            File.join(context.site.global_new_url,
                      context.request.non_canonicalised_fullpath)
          else
            context.site.global_new_url
          end
          guarded_redirect(new_url)
        when '410'
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
        else
          message = "Can't serve unexpected global_http_status: #{context.site.global_http_status} for #{context.site.abbr}"
          [500, { 'Content-Type' => 'text/plain'}, [message]]
        end
      end
    end
  end
end
