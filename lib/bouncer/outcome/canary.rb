module Bouncer
  module Outcome
    class Canary < Base
      HEADERS = {
        'Content-Type' => 'text/plain',
        # FIXME: stop this being overridden by our cacher middleware:
        'Cache-Control' => 'private'
      }

      def serve
        if can_select_from_required_tables?
          [200, HEADERS, ['OK: The canary is alive']]
        else
          [500, HEADERS, ['Internal Server Error']]
        end
      end

      def can_select_from_required_tables?
        # At this point we've already SELECTed from the hosts table.

        # Check that Bouncer can SELECT from the sites and mappings tables:
        test_mapping = context.mappings.where(type: 'redirect').first

        # Check that Bouncer can SELECT from the organisations and
        # whitelisted_hosts tables:
        organisation && test_mapping && legal_redirect?(test_mapping.new_url)
      end
    end
  end
end
