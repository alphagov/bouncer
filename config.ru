require './boot'
require 'rack/static'

use Bouncer::Cacher

if ENV['RACK_ENV'] == 'production'
  aws_secrets           = File.expand_path('config/aws_secrets.yml', File.dirname(__FILE__))
  exception_mail_config = File.expand_path('config/exception_mail_config.yml', File.dirname(__FILE__))

  if File.exist?(aws_secrets) && File.exist?(exception_mail_config)
    use ExceptionMailer, YAML.load_file(aws_secrets), YAML.load_file(exception_mail_config)
  else
    raise "Missing configuration file: cannot send exception notifications"
  end
end

# We need compatibility with redirector which serves its assets from '/''.
# This is useful because then we can run redirector's tests unmodified against
# Bouncer.
#
# Turn public/foo.css into /foo.css
urls = ["/favicon.ico"] + Dir["public/*.css", "public/*.png"].map { |path| path.gsub("public", "") }
use Rack::Static, urls: urls, root: 'public'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Bouncer::App.new
