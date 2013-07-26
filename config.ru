require './boot'
require 'rack/static'

use Rack::Static, urls: %w(/favicon.ico /images /robots.txt /stylesheets), root: 'public'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Bouncer.new
