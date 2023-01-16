require "bundler/setup"
require "bootsnap"
RACK_ENV = ENV.fetch("RACK_ENV", "development")
Bootsnap.setup(
  cache_dir: ENV.fetch("BOOTSNAP_CACHE_DIR", "tmp/cache"),
  development_mode: RACK_ENV == "development",
)

require "active_record"
require "erb"
require "yaml"

def db_config_from_yaml
  path = File.expand_path("config/database.yml", __dir__)
  YAML.safe_load(ERB.new(File.read(path)).result)
end

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || db_config_from_yaml[RACK_ENV])

$LOAD_PATH.unshift File.expand_path("lib", __dir__)

require "bouncer"
