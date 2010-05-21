require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))
require 'fixtures/test_base_class'
require 'fixtures/other_class'
require 'fixtures/test_class'

describe TestClass do

  let(:object) {TestClass.new(:foo)}

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
      stub_request(:put, "http://fred:pass@myserver/path/update/99.ext").to_return(:body => 'updated data')
      TestClass.new(:var => 99).update
    end
  end

  describe 'building connected objects' do
    it 'build the requested response object' do
        stub_request(:put, "http://fred:pass@myserver/path/update/99.ext").to_return(:body => 'updated data')
        TestClass.new(:var => 99).update.should == OtherClass.new('updated data')
    end

    it 'passes the raw result back when requested' do
      stub_request(:post, "http://fred:pass@myserver/path/save/file").with(:body => "data=somedata").to_return(:body => 'saved data')
      TestClass.save('somedata').should == 'saved data'
    end

    it 'builds the result using the specified method' do
      stub_request(:delete, "http://fred:pass@myserver/path/delete").to_return(:body => 'deleted OK')
      TestClass.destroy.should be_true
    end

    it 'builds the result using the specified proc' do
      stub_request(:get, "http://fred:pass@myserver/path/foo?value=908").to_return(:body => 'foo data')
      TestClass.foo(908).should == 'New foo data Improved'
    end

    it 'builds each value in an array individually' do
      stub_request(:get, "http://fred:pass@myserver/path/foo?value=908").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '[foo,data]')
      TestClass.foo(908).should == ['New foo Improved', 'New data Improved']
    end
  end

  describe 'populating properties' do
    it 'populates result values' do
      stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{value2:"value2", value4:"ignored"}')
      result = TestClass.fetch_json
      result.value2.should == 'value2'
      result.value3.should == nil
      result.should_not be_respond_to(:value4)
    end

    it 'populates renamed values' do
      stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{input_name:"value"}')
      result = TestClass.fetch_json
      result.value.should == 'value'
    end

    it 'populates nested values' do
      stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{block:{var:"value"}}')
      result = TestClass.fetch_json
      result.nested_value.should == 'value'
    end

    it 'falls back to populating based on the property name if from is not found' do
      stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{value:"value"}')
      result = TestClass.fetch_json
      result.value.should == 'value'
    end

    it 'populates a property as another class' do
      stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{other: "value"}')
      result = TestClass.fetch_json
      result.other.should == OtherClass.new('value')
    end

    it 'populates a property with a proc' do
      stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{processed: "value"}')
      result = TestClass.fetch_json
      result.processed.should == "Processed: value"
    end

    it 'does not build null data' do
      stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{processed: null}')
      result = TestClass.fetch_json
      result.processed.should == nil
    end

    it 'builds each value when populating an array' do
      stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{processed: [1,2,3,4]}')
      result = TestClass.fetch_json
      result.processed.should == ['Processed: 1','Processed: 2','Processed: 3','Processed: 4']
    end
  end
end
