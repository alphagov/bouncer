require './boot'
require 'rack/static'

require 'exception_mailer'

if ENV['RACK_ENV'] == 'production'
  airbrake_config = File.expand_path('config/airbrake_production.yml', File.dirname(__FILE__))

  if File.exist?(airbrake_config)
    env_config = YAML.load_file(airbrake_config)
    Airbrake.configure do |config|
      config.api_key = env_config[:api_key]
      config.secure = env_config[:secure]
      config.host = env_config[:host]
      config.environment_name = env_config[:environment_name]
    end
    use Airbrake::Rack
  end
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
