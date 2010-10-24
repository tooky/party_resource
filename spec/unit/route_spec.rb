require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))

describe PartyResource::Route do

  subject { PartyResource::Route.new options }

  let_mock(:path)
  let_mock(:object)
  let_mock(:parsed_response)
  let(:raw_result) { mock(:raw_result, :parsed_response => parsed_response) }
  let(:connector) { mock(:connector, :fetch => raw_result) }
  let(:klass) { Class.new {def initialize(data); end} }
  let(:options) { { :get => path, :as => klass } }

  before do
    PartyResource::Connector.stub(:lookup => connector)
  end

  describe ".call" do

    [:get, :put, :post, :delete].each do |verb|

      context "for a #{verb} request" do
        let(:options) { { verb => path, :as => klass } }

        it "performs a #{verb} request to the path with the connector" do
          request = mock(:request)
          PartyResource::Request.should_receive(:new).with(verb, path, object, anything, anything).and_return(request)
          connector.should_receive(:fetch).with(request)
          subject.call(object)
        end
      end
    end

    context 'with more than one verb passed' do
      let(:options) { { :post => path, :get => path } }

      it "raises an argument error" do
        lambda{ subject.call(object) }.should raise_error(ArgumentError)
      end
    end

    context "with no variables" do
      let(:options) { { :get => path, :as => klass } }

      it "builds the request path" do
        PartyResource::Request.should_receive(:new).with(:get, path, object, {}, anything)
        subject.call(object)
      end

    end

    context "with some variables" do
      let(:options) { { :get => path, :with => [:a, :b, :c], :as => klass } }

      it "builds the request path" do
        PartyResource::Request.should_receive(:new).with(:get, path, object, {:a => 1, :b => 2, :c => 3}, anything)
        subject.call(object, 1, 2, 3)
      end

      it "raises an ArgumentError for the wrong number of arguments" do
        lambda { subject.call(object, 1, 2, 3, 4) }.should raise_error(ArgumentError)
        lambda { subject.call(object) }.should raise_error(ArgumentError)
      end
    end

    context 'when returning as class' do
      let_mock(:result_object)

      it 'builds an object from the data returned' do
        klass.should_receive(:new).with(parsed_response).and_return(result_object)
        subject.call(object).should == result_object
      end
    end

    context 'when returning as :raw' do
      let(:options) { { :get => path, :as => :raw } }
      it 'builds an object from the data returned' do
        klass.should_not_receive(:new)
        subject.call(object).should == parsed_response
      end
    end

    context 'when returning as class with builder method' do
      let_mock(:result_object)
      let(:options) { { :get => path, :as => [klass, :builder] } }

      it 'builds an object from the data returned' do
        klass.should_receive(:builder).with(parsed_response).and_return(result_object)
        subject.call(object).should == result_object
      end
    end

    context 'when returning as proc' do
      let_mock(:result_object)
      let(:options) { { :get => path, :as => lambda {|data| data.morph } } }

      it 'builds an object from the data returned' do
        parsed_response.should_receive(:morph).and_return(result_object)
        subject.call(object).should == result_object
      end
    end

    context 'when returning an array' do
      let(:parsed_response) { [1, 2] }
      let(:options) { { :get => path, :as => lambda {|data| "X#{data}" } } }
      it 'builds each value individually' do
        subject.call(object).should == %w{ X1 X2 }
      end
    end

    context 'with an extra params hash' do
      it '' do
        lambda { subject.call(object, {:params => :data}) }.should_not raise_error
      end
    end

  end
end
