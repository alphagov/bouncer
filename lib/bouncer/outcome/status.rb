module Bouncer
  module Outcome
    class Status < Base
      def serve
        Bouncer::PreemptiveRules.try(context, renderer) or
          mapping or
          Bouncer::FallbackRules.try(context, renderer) or
          not_found
      end

      def mapping
        if context.mapping
          case context.mapping.try(:type)
          when "redirect"
            guarded_redirect(context.mapping.new_url)
          when "unresolved", "archive"
            [410, { "Content-Type" => "text/html" }, [renderer.render(context.attributes_for_render, 410)]]
          end
        end
      end

      def not_found
        [404, { "Content-Type" => "text/html" }, [renderer.render(context.attributes_for_render, 404)]]
      end
    end
  end
end
