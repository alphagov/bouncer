module Bouncer
  class Base < Struct.new(:context, :renderer)
    extend Forwardable

    def_delegators :context, :request

  private
    def guarded_redirect(url)
      if legal_redirect?(url)
        ['301', { 'Location' => url }, []]
      else
        [500, { 'Content-Type' => 'text/plain' }, "Refusing to redirect to non *.gov.uk domain: #{url}"]
      end
    end

    def legal_redirect?(url)
      URI.parse(url).host =~ /.*\.gov\.uk\z/
    end
  end
end
