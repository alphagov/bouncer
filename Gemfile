source "https://rubygems.org/"

gem "activerecord", "7.0.2" # Ideally version should be synced with Transition
gem "erubis", "2.7.0"
gem "govuk_app_config"
gem "nokogiri", "1.13.6"
gem "optic14n", "2.1.0" # Ideally version should be synced with Transition
gem "pg"
gem "rack", "~> 2.2.3"
gem "rake", "13.0.1"

group :development do
  gem "mr-sparkle", "0.3.0"
end

group :test do
  gem "database_cleaner", "1.8.5"
  gem "pry"
  gem "rack-test", "2.0.0"
  gem "simplecov"
end

group :development, :test do
  gem "rspec"
  gem "rubocop-govuk", require: false # Trialling pre-release
end
