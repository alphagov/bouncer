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
      ENV["PGPASSWORD"] = uri.password if uri.password
      port = "-p #{uri.port}" if uri.port
      database = uri.path.delete_prefix("/")
    end

    sh "dropdb #{port} #{host} #{user} --if-exists #{database}"
    sh "createdb #{port} #{host} #{user} --encoding=UTF8 --template=template0 #{database}"
    sh "cat db/structure.sql | psql #{port} #{host} #{user} -d #{database}"
  end
end
