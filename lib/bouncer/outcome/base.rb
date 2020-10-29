module Bouncer
  module Outcome
    Base = Struct.new(:context, :renderer) do
      extend Forwardable

      def_delegators :context, :request

      private

      def guarded_redirect(url)
        if legal_redirect?(url)
          [301, { "Location" => url }, []]
        else
          [501, { "Content-Type" => "text/plain" }, "Refusing to redirect to non-whitelisted domain: #{url}"]
        end
      end

      def legal_redirect?(url)
        host = Addressable::URI.parse(url).host
        host.end_with?(".gov.uk") || host.end_with?(".mod.uk") || host.end_with?(".nhs.uk") || WhitelistedHost.exists?(hostname: host)
      end
    end
  end
end
