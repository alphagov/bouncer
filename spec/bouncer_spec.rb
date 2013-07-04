require 'spec_helper'

require 'rack/test'
require_relative '../lib/bouncer'

describe Bouncer do
  include Rack::Test::Methods

  let(:app) { subject }

  it 'should respond to requests' do
    expect { get '/' }.to_not raise_error
  end
end
