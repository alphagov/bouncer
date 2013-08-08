module Bouncer
  class Base < Struct.new(:context, :renderer)
    extend Forwardable

    def_delegators :context, :request
  end
end
