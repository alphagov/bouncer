module Bouncer
  module Outcome
    class Canary < Base
      HEADERS = {
        'Content-Type' => 'text/plain',
        # FIXME: stop this being overridden by our cacher middleware:
        'Cache-Control' => 'private'
      }

      def serve
        if is_alive?
          [200, HEADERS, ['OK: The canary is alive']]
        else
          [503, HEADERS, ['Service Unavailable']]
        end
      end

    private
      def is_alive?
        # We want to make sure we can select from each of these tables
        # and that each of these tables returns something.

        begin
          # At this point we've already SELECTed from the hosts table.

          # Check for the site
          test_site = context.site

          # Check that Bouncer can SELECT from the mappings table:
          test_mapping = context.mappings.first

          # Check that there is a WhitelistedHost
          test_whitelisted_host = WhitelistedHost.first

          # Check that Bouncer can SELECT from the organisations table
          # and test that the results of the previous 2 queries are not nil
          test_site && context.organisation && test_mapping && test_whitelisted_host
        rescue
          false
        end
      end
    end
  end
end
