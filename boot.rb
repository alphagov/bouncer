require "bundler/setup"

require "active_record"
require "erb"
require "yaml"

RACK_ENV ||= ENV["RACK_ENV"] || "development"

if ENV["DATABASE_URL"]
  ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
else
  ActiveRecord::Base.establish_connection(YAML.safe_load(ERB.new(File.read(File.expand_path("config/database.yml", __dir__))).result)[RACK_ENV])
end

$LOAD_PATH.unshift File.expand_path("lib", __dir__)

require "bouncer"
