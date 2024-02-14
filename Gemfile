source "https://rubygems.org/"

gem "activerecord", "7.1.3" # Ideally version should be synced with Transition
gem "bootsnap", require: false
gem "erubis", "2.7.0"
gem "govuk_app_config", "~> 9.9.1"
gem "nokogiri", "1.16.2"
gem "optic14n", "2.1.0" # Ideally version should be synced with Transition
gem "pg"
gem "rack", "~> 2.2.8"
gem "rake", "13.1.0"

group :development do
  gem "mr-sparkle", "0.3.0"
end

group :test do
  gem "database_cleaner", "2.0.2"
  gem "pry"
  gem "rack-test", "2.1.0"
  gem "simplecov"
end

group :development, :test do
  gem "rspec"
  gem "rubocop-govuk", require: false # Trialling pre-release
end
