require 'active_record'
RACK_ENV ||= ENV['RACK_ENV'] || 'development'

if ENV['DATABASE_URL']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(YAML.load(File.read(File.expand_path('../config/database.yml', __FILE__)))[RACK_ENV])
end

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'bouncer'
