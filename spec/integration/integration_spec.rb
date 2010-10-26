require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))
require 'fixtures/test_base_class'
require 'fixtures/other_class'
require 'fixtures/test_class'

describe TestClass do

  let(:object) {TestClass.new(:foo)}

  after do
    PartyResource.logger = nil
  end

  describe 'class level call' do
    it 'raises an argument error when called with the wrong number of arguments' do
      lambda { TestClass.find }.should raise_error(ArgumentError)
    end

    it 'finds an object' do
      stub_request(:get, "http://fred:pass@myserver/path/find/99.ext").to_return(:body => 'some data')
      TestClass.find(99).should == TestClass.new('some data')
    end

    it 'finds an object with extra options' do
      stub_request(:get, "http://fred:pass@myserver/path/find/99.ext?extra=options").to_return(:body => 'some data')
      TestClass.find(99, :extra => 'options').should == TestClass.new('some data')
    end

    it 'uses other connectors' do
      stub_request(:get, 'http://otherserver/url').to_return(:body => 'from the otherserver')
      OtherPartyClass.test.should == 'from the otherserver'
    end
  end

  context 'passing options to the HTTP request' do
    it 'passes the headers correctly' do
      stub_request(:get, "http://fred:pass@myserver/path/find/99.ext").with(:headers => { 'Content-type' => 'test/header-value' })
      TestClass.find(99)
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

    it 'passes "included" variables to the new object' do
      v2 = mock(:v2)
      stub_request(:get, "http://fred:pass@myserver/path/include").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{}')
      test = TestClass.from_json(:value2 => v2)
      test.include.should == OtherClass.new(:thing => v2)
    end

    context 'error cases' do
      it 'raises ResourceNotFound' do
        stub_request(:delete, "http://fred:pass@myserver/path/delete").to_return(:status => 404)
        lambda { TestClass.destroy }.should raise_error(PartyResource::Exceptions::ResourceNotFound)
      end

      it 'raises ResourceInvalid' do
        stub_request(:delete, "http://fred:pass@myserver/path/delete").to_return(:status => 422)
        lambda { TestClass.destroy }.should raise_error(PartyResource::Exceptions::ResourceInvalid)
      end

      it 'raises ClientError' do
        stub_request(:delete, "http://fred:pass@myserver/path/delete").to_return(:status => 405)
        lambda { TestClass.destroy }.should raise_error(PartyResource::Exceptions::ClientError)
      end

      it 'raises ServerError' do
        stub_request(:delete, "http://fred:pass@myserver/path/delete").to_return(:status => 501)
        lambda { TestClass.destroy }.should raise_error(PartyResource::Exceptions::ServerError)
      end

      it 'rescues exceptions' do
        stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:status => 404)
        TestClass.fetch_json.should be_nil
      end

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

    context 'and inherited class' do
      it 'self refers to the child class' do
        stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{value2:"value2", child_property:"child"}')
        result = InheritedTestClass.fetch_json
        result.should be_a(InheritedTestClass)
      end

      it 'all local and inherited properties are available' do
        stub_request(:get, "http://fred:pass@myserver/path/big_data").to_return(:headers => {'Content-Type' => 'text/json'}, :body => '{value2:"value2", child_property:"child"}')
        result = InheritedTestClass.fetch_json
        result.child_property.should == 'child'
        result.value2.should == 'value2'
      end
    end
  end

  describe '#to_property_hash' do
    it 'converts an object to external hash representation' do
      obj = TestClass.from_json(:value => 'v1', :value2 => 'v2', :nested_value => 'nv', :processed => 'Milk', :child => {:thing => 'Happiness'})
      obj.to_properties_hash.should == {:input_name => 'v1', :value2 => 'v2', :block => {:var => 'nv'}, :output_name => 'Processed: Milk', :child => {:thing => 'Happiness'}}
    end
  end

  describe 'logging' do
    class TestLogger
      attr_reader :text

      def initialize
        @text = []
      end

      def debug(text)
        @text << text
      end
    end

    context 'with no logger' do
      it 'does not fail' do
        stub_request(:get, "http://fred:pass@myserver/path/find/99.ext").to_return(:body => 'some data')
        TestClass.find(99)
      end
    end

    context 'with a logger object' do
      before do
        @logger = TestLogger.new
        PartyResource.logger = @logger
      end

      it 'logs all api calls to debug' do
        stub_request(:get, "http://fred:pass@myserver/path/find/99.ext").to_return(:body => 'some data')

        TestClass.find(99)

        @logger.text.first.should match(/^\*\* PartyResource GET call to \/find\/99.ext with \{/)
        @logger.text.first.should match(/:basic_auth=>\{/)
        @logger.text.first.should match(/:username=>"fred"/)
        @logger.text.first.should match(/:password=>"pass"/)
        @logger.text.first.should match(/:base_uri=>"http:\/\/myserver\/path"/)
      end
    end

    context 'with a logger lambda' do
      before do
        PartyResource.logger = lambda {|message| @message = message}
      end

      it 'logs all api calls to debug' do
        stub_request(:get, "http://fred:pass@myserver/path/find/99.ext").to_return(:body => 'some data')

        TestClass.find(99)

        @message.should match(/^\*\* PartyResource GET call to \/find\/99.ext with \{/)
        @message.should match(/:basic_auth=>\{/)
        @message.should match(/:username=>"fred"/)
        @message.should match(/:password=>"pass"/)
        @message.should match(/:base_uri=>"http:\/\/myserver\/path"/)
      end
    end

  end
end
