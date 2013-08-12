module Bouncer
  class Base < Struct.new(:context, :renderer)
    extend Forwardable

    def_delegators :context, :request

  private
    def legal_redirect?(url)
      URI.parse(url).host =~ /.*\.gov\.uk\z/
    end

    def render_illegal_redirect(url)
      [500, { 'Content-Type' => 'text/plain' }, "Refusing to redirect to non *.gov.uk domain: #{url}"]
    end
  end
end
