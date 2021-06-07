require './boot'
require 'rack/static'
require './lib/active_record/rack/connection_management'

use Raven::Rack
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
run Bouncer::App.new
