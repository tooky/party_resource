require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/test_class')

describe TestClass do

  it 'should find an object' do
    TestClass.find.should == TestClass.new(:some => :data)
  end
end
