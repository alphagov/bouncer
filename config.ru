require './boot'
require 'rack/static'

use Rack::Static, urls: %w(css gif ico png), root: 'static'
run Bouncer.new
