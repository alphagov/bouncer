module Bouncer
  class Base < Struct.new(:context, :renderer)
    extend Forwardable

    def_delegators :context, :request

  private
    def guarded_redirect(url)
      if legal_redirect?(url)
        [301, { 'Location' => url }, []]
      else
        [501, { 'Content-Type' => 'text/plain' }, "Refusing to redirect to non-whitelisted domain: #{url}"]
      end
    end

    def legal_redirect?(url)
      host = URI.parse(url).host
      host.end_with?('.gov.uk') || whitelist.include?(host)
    end

    def whitelist
      # Cache the list for the lifetime of the process
      @@whitelist ||= begin
        lines = File.open('config/whitelist.txt').map(&:chomp)
        usable_lines = lines.reject { |line| line.start_with?('#') || line.empty? }
        # Set dedupes but also gives better lookup performance
        Set.new(usable_lines)
      end
    end
  end
end
