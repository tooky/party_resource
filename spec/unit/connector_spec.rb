require 'spec_helper'

describe PartyResource::Connector do
  describe '#lookup' do

    let(:test_connector) { mock(:connector) }
    let(:default_connector) { mock(:connector) }
    let(:connectors) { { :test => test_connector, :other => default_connector } }

    before do
      PartyResource::Connector::Base.stub(:connectors => connectors)
    end

    it "returns the named connectors" do
      PartyResource::Connector.lookup(:test).should == test_connector
    end

    it "returns the default connector for nil name" do
      PartyResource::Connector::Base.stub(:default => :other)

      PartyResource::Connector.lookup(nil).should == default_connector
    end
  end
end
