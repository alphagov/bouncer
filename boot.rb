require 'active_record'
RACK_ENV ||= ENV['RACK_ENV'] || 'development'
ActiveRecord::Base.establish_connection(YAML.load(File.read(File.expand_path('../config/database.yml', __FILE__)))[RACK_ENV])

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'bouncer'
