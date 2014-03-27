require './boot'
require 'rack/static'

if ENV['RACK_ENV'] == 'production'
  require './config/airbrake'
  use Airbrake::Rack
end

use Bouncer::Cacher

# We need compatibility with redirector which serves its assets from '/''.
# This is useful because then we can run redirector's tests unmodified against
# Bouncer.
#
# Turn public/foo.css into /foo.css
urls = ["/favicon.ico"] + Dir["public/*.css", "public/*.png"].map { |path| path.gsub("public", "") }
use Rack::Static, urls: urls, root: 'public'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Bouncer::App.new
