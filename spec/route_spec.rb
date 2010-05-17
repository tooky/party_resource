require 'spec_helper'

describe PartyResource::Route do

  subject { PartyResource::Route.new options }

  let(:path) { mock(:path) }
  let(:object) { mock(:object) }
  let(:connector) { mock(:connector, :null_object => true) }

  before do
    PartyResource.stub(:Connector => connector)
  end

  describe ".call" do

    [:get, :put, :post, :delete].each do |verb|

      context "for a #{verb} request" do
        let(:options) { { verb => path } }

        it "performs a #{verb} request to the path with the connector" do
          path_object = mock(:path_object)
          PartyResource::Path.stub(:new => path_object)
          connector.should_receive(verb).with(path_object)
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
        PartyResource::Path.should_receive(:new).with(path, object, [])
        subject.call(object)
      end

    end

  end
end
