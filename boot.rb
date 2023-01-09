require "bundler/setup"
require "bootsnap"
Bootsnap.setup(cache_dir: ENV["BOOTSNAP_CACHE_DIR"] || "tmp/cache")

require "active_record"
require "erb"
require "yaml"

RACK_ENV ||= ENV["RACK_ENV"] || "development"

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || YAML.safe_load(ERB.new(File.read(File.expand_path("config/database.yml", __dir__))).result)[RACK_ENV])

$LOAD_PATH.unshift File.expand_path("lib", __dir__)

require "bouncer"
