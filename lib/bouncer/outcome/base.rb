module Bouncer
  class Base
    attr_accessor :context, :options

    def initialize(context, options = {})
      self.context = context
      self.options = options
    end
  end
end