require './boot'
require 'rack/static'

use Rack::Static, urls: %w(/favicon.ico /images /stylesheets), root: 'public'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Bouncer.new
