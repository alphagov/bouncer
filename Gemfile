source "https://rubygems.org/"

gem "activerecord", "~> 6.0.3" # Ideally version should be synced with Transition
gem "erubis", "2.7.0"
gem "govuk_app_config"
gem "nokogiri", "1.12.5"
gem "optic14n", "2.1.0" # Ideally version should be synced with Transition
gem "pg", "1.3.3"
gem "rack", "~> 2.2.3"
gem "rake", "13.0.1"

group :development do
  gem "mr-sparkle", "0.3.0"
end

group :test do
  gem "database_cleaner", "1.8.5"
  gem "pry"
  gem "rack-test", "1.1.0"
  gem "simplecov"
end

group :development, :test do
  gem "rspec"
  gem "rubocop-govuk", "4.0.0.pre.1", require: false # Trialling pre-release
end
