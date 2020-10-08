require "rack/test"
require "benchmark"

module Benchmark
  ##
  # Tests Bouncer using Rack::Test with a combination of host not found/
  # path not found/archive/redirects, defaulting to 1000 requests each.
  #
  # Not to be used for production performance testing - this is in-memory
  # and serves only as a basis for making relative code improvements.
  #
  class All
    include Rack::Test::Methods

    DEFAULT_NUMBER_OF_RUNS = 1000

    attr_accessor :number_of_runs
    def initialize(number_of_runs)
      self.number_of_runs = (number_of_runs || DEFAULT_NUMBER_OF_RUNS).to_i
    end

    def app
      @app ||= Rack::Builder.parse_file("config.ru")[0]
    end

    def run!
      Benchmark.bm(7) do |x|
        x.report("no host:") { number_of_runs.times { get "http://www.fluffy.gov.uk/news"     } }
        x.report("410:")     { number_of_runs.times { get "http://www.direct.gov.uk/news"     } }
        x.report("301:")     { number_of_runs.times { get "http://www.direct.gov.uk/motoring" } }
        x.report("404:")     { number_of_runs.times { get "http://www.direct.gov.uk/prickly"  } }
      end
    end
  end
end
