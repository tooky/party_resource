require 'spec_helper'
require 'fixtures/test_class'

describe TestClass do

  describe 'find' do
    it 'raises an argument error when called with the wrong number of arguments' do
      lambda { TestClass.find }.should raise_error(ArgumentError)
    end

    it 'finds an object' do
      stub_request(:get, "http://fred:pass@myserver/path/things/99.ext")
      TestClass.find(99).should == TestClass.new(:some => :data)
    end
  end
end
