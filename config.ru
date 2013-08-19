require './boot'
require 'rack/static'

use Bouncer::C14nizer
use Bouncer::Cacher
use Rack::Static, urls: %w(/favicon.ico /images /), root: 'public'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Bouncer::App.new
