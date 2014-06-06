module Bouncer
  module Outcome
    class GlobalType < Base
      def serve
        case context.site.global_type
        when 'redirect'
          new_url = if context.site.global_redirect_append_path
            File.join(context.site.global_new_url,
                      context.request.non_canonicalised_fullpath)
          else
            context.site.global_new_url
          end
          guarded_redirect(new_url)
        when 'archive'
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
        else
          message = "Can't serve unexpected global_type: #{context.site.global_type} for #{context.site.abbr}"
          [500, { 'Content-Type' => 'text/plain'}, [message]]
        end
      end
    end
  end
end
