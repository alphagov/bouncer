require 'govuk_app_config'

if ENV['RACK_ENV'] != "production"
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
end

namespace :db do
  task :reset do
    sh "dropdb --if-exists transition_test"
    sh "createdb --encoding=UTF8 --template=template0 transition_test"
    sh "cat db/structure.sql | psql -d transition_test"
  end
end
