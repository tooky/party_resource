$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'party_resource'
require 'spec'
require 'spec/autorun'
require 'webmock/rspec'

include WebMock::API

module LetMock
  def let_mock(name, options = {})
    let(name) { mock(name, options) }
  end
end

Spec::Runner.configure do |config|
  config.extend(LetMock)
end

