require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))

describe PartyResource::Route do

  subject { PartyResource::Route.new options }

  let_mock(:path)
  let_mock(:object)
  let_mock(:raw_result)
  let(:connector) { mock(:connector, :fetch => raw_result) }
  let_mock(:klass, :new => nil)
  let(:options) { { :get => path, :as => klass } }

  before do
    PartyResource.stub(:Connector => connector)
  end

  describe ".call" do

    [:get, :put, :post, :delete].each do |verb|

      context "for a #{verb} request" do
        let(:options) { { verb => path, :as => klass } }

        it "performs a #{verb} request to the path with the connector" do
          request = mock(:request)
          PartyResource::Request.should_receive(:new).with(verb, path, object, anything).and_return(request)
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
        PartyResource::Request.should_receive(:new).with(:get, path, object, {})
        subject.call(object)
      end

    end

    context "with some variables" do
      let(:options) { { :get => path, :with => [:a, :b, :c], :as => klass } }

      it "builds the request path" do
        PartyResource::Request.should_receive(:new).with(:get, path, object, {:a => 1, :b => 2, :c => 3})
        subject.call(object, 1, 2, 3)
      end

      it "raises an ArgumentError for the wrong number of arguments" do
        lambda { subject.call(object, 1, 2, 3, 4) }.should raise_error(ArgumentError)
        lambda { subject.call(object) }.should raise_error(ArgumentError)
      end
    end

    context 'when returning as self' do
      let_mock(:result_object)

      it 'builds an object from the data returned' do
        klass.should_receive(:new).with(raw_result).and_return(result_object)
        subject.call(object).should == result_object
      end
    end

  end
end
