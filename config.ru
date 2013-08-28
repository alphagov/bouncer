require './boot'
require 'rack/static'

use Bouncer::Cacher
use Rack::Static, urls: %w(/favicon.ico /images /stylesheets), root: 'public'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Bouncer::App.new
