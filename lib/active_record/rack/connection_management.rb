# This functionality has been removed from ActiveRecord
# see: https://github.com/rails/rails/issues/26947#issuecomment-265372902
module ActiveRecord
  module Rack
    class ConnectionManagement
      def initialize(app)
        @app = app
      end

      def call(env)
        testing = env["rack.test"]
        response = @app.call(env)
        ActiveRecord::Base.connection_handler.clear_active_connections! unless testing
        response
      rescue StandardError
        ActiveRecord::Base.connection_handler.clear_active_connections! unless testing
        raise
      end
    end
  end
end
