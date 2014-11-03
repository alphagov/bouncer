require 'airbrake'
require 'airbrake_tasks'

if ENV['RACK_ENV'] != "production"
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
end

namespace :errbit do
  desc 'Notify Errbit of a deploy'
  task :deploy do
    require './config/airbrake'

    # This should use Airbrake.configuration, including the API key
    AirbrakeTasks.deploy(:rails_env      => ENV['TO'],
                         :scm_revision   => ENV['REVISION'],
                         :scm_repository => ENV['REPO'],
                         :local_username => ENV['USER'],
                         :dry_run        => ENV['DRY_RUN'])
  end
end
