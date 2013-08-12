module Bouncer
  module Outcome
    class Status < Base
      def serve
        case context.mapping.try(:http_status)
        when '301'
          if legal_redirect?(context.mapping.new_url)
            [301, { 'Location' => context.mapping.new_url }, []]
          else
            [500, { 'Content-Type' => 'text/plain' }, "Refusing to redirect to non *.gov.uk domain: #{context.mapping.new_url}"]
          end
        when '410'
          [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
        else
          if request.path == '/410'
            [410, { 'Content-Type' => 'text/html' }, [renderer.render(context, 410)]]
          else
            Bouncer::Rules.try(request, renderer) or
              [404, { 'Content-Type' => 'text/html' }, [renderer.render(context, 404)]]
          end
        end
      end

    private
      def legal_redirect?(url)
        URI.parse(url).host =~ /.*\.gov\.uk\z/
      end
    end
  end
end
