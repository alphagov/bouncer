require './boot'
require 'rack/static'
require 'exception_mailer'

initializers_path = File.expand_path('config/initializers/*.rb', File.dirname(__FILE__))
Dir[initializers_path].each { |f| require f }

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
