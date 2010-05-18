require 'spec_helper'

describe PartyResource::Route do

  subject { PartyResource::Route.new options }

  let_mock(:path)
  let_mock(:object)
  let(:connector) { mock(:connector, :null_object => true) }

  before do
    PartyResource.stub(:Connector => connector)
  end

  describe ".call" do

    [:get, :put, :post, :delete].each do |verb|

      context "for a #{verb} request" do
        let(:options) { { verb => path } }

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

    context "with a no named variables" do
      let(:options) { { :get => path } }

      it "builds the request path" do
        PartyResource::Request.should_receive(:new).with(:get, path, object, [])
        subject.call(object)
      end

    end

  end
end
