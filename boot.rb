require "bundler/setup"
require "bootsnap"
Bootsnap.setup(cache_dir: ENV["BOOTSNAP_CACHE_DIR"] || "tmp/cache")

require "active_record"
require "erb"
require "yaml"

def db_config_from_yaml
  path = File.expand_path("config/database.yml", __dir__)
  YAML.safe_load(ERB.new(File.read(path)).result)
end

RACK_ENV ||= ENV["RACK_ENV"] || "development"
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || db_config_from_yaml[RACK_ENV])

$LOAD_PATH.unshift File.expand_path("lib", __dir__)

require "bouncer"
