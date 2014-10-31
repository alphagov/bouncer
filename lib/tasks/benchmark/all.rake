require 'benchmark/all'

namespace :benchmark do
  desc 'Benchmark a selection of query types'
  task :all, [:number_of_runs] do |_, args|
    Benchmark::All.new(args[:number_of_runs]).run!
  end
end
