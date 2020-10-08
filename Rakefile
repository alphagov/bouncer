require "govuk_app_config"
require "uri"

if ENV["RACK_ENV"] != "production"
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
end

namespace :db do
  desc "Drop test database and create a new one, named to match db:reset for Jenkins"
  task :reset do
    if ENV["TEST_DATABASE_URL"]
      uri = URI.parse(ENV["TEST_DATABASE_URL"])
      host = "-h #{uri.host}"
      user = "-U #{uri.user}"
    end

    sh "dropdb #{host} #{user} --if-exists transition_test"
    sh "createdb #{host} #{user} --encoding=UTF8 --template=template0 transition_test"
    sh "cat db/structure.sql | psql #{host} #{user} -d transition_test"
  end
end
