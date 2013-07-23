require './boot'
require 'rack/static'

use Rack::Static, urls: %w(/favicon.ico /images /stylesheets), root: 'public'
run Bouncer.new
