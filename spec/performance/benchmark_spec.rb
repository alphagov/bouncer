require_relative "../../boot"
require_relative "../../lib/benchmark/all"

describe "Benchmarking", performance: true do
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file("config.ru")[0]
  end

  let(:number_of_runs) { ENV["NUMBER_OF_RUNS"] || 1000 }

  it "generates timings for no host, 301, 410, 404" do
    Benchmark::All.new(number_of_runs).run!
  end
end
