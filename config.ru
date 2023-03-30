require './boot'
require 'rack/static'
require './lib/active_record/rack/connection_management'

use Sentry::Rack::CaptureExceptions
use Bouncer::Cacher

# We need compatibility with redirector which serves its assets from '/''.
# This is useful because then we can run redirector's tests unmodified against
# Bouncer.
#
# Turn public/foo.css into /foo.css
urls = ["/favicon.ico"] + Dir["public/*.css", "public/*.png", "public/*.js"].map { |path| path.gsub("public", "") }
use Rack::Static, urls: urls, root: 'public'

ActiveRecord::QueryCache.run
use ActiveRecord::Rack::ConnectionManagement

app = Rack::Builder.new do |builder|
	if GovukPrometheusExporter.should_configure
		require "prometheus_exporter"
		require "prometheus_exporter/middleware"

		builder.use PrometheusExporter::Middleware, instrument: :prepend
	end
	builder.run Bouncer::App.new
end
run app
