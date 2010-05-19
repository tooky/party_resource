require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))
require 'fixtures/test_base_class'
require 'fixtures/other_class'
require 'fixtures/test_class'

describe TestClass do

  describe 'class level call' do
    it 'raises an argument error when called with the wrong number of arguments' do
      lambda { TestClass.find }.should raise_error(ArgumentError)
    end

    it 'finds an object' do
      stub_request(:get, "http://fred:pass@myserver/path/find/99.ext").to_return(:body => 'some data')
      TestClass.find(99).should == TestClass.new('some data')
    end
  end

  describe 'instance level call' do
    it 'gets the result' do
      stub_request(:get, "http://fred:pass@myserver/path/update/99.ext").to_return(:body => 'updated data')
      TestClass.new(:var => 99).update
    end
  end

  it 'build the requested response object' do
      stub_request(:get, "http://fred:pass@myserver/path/update/99.ext").to_return(:body => 'updated data')
      TestClass.new(:var => 99).update.should == OtherClass.new('updated data')
  end

  it 'passes the raw result back when requested' do
    stub_request(:get, "http://fred:pass@myserver/path/save/file?data=somedata").to_return(:body => 'saved data')
    TestClass.save('somedata').should == 'saved data'
  end
end
