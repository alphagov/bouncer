source 'https://rubygems.org/'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'activerecord', '4.0.2' # This is a mismatch for Transition, which has 3.2.x
gem 'aws-ses', '0.5.0'
gem 'mysql2', '0.3.11'
gem 'nokogiri', '1.6.0'
gem 'rack', '1.5.2'
gem 'optic14n', '1.0.0' # Ideally version should be synced with Transition
gem 'erubis', '2.7.0'
gem 'airbrake', '3.1.15'

group :production do
  gem 'unicorn', '4.6.3'
end

group :development do
  gem "mr-sparkle", '0.2.0'
end

group :test do
  gem 'database_cleaner', '1.0.1'
  gem 'rack-test', '0.6.2'
  gem 'rake', '10.1.0'
  gem 'rspec', '2.13.0'
end
