require 'spec_helper'
require 'fixtures/test_class'

describe TestClass do

  it 'should find an object' do
    TestClass.find.should == TestClass.new(:some => :data)
  end
end
