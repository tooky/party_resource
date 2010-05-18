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

  describe '#default=' do
    it 'sets the default connector name' do
      name = mock(:name)
      PartyResource::Connector.default = name
      PartyResource::Connector::Base.default.should == name
    end
  end

  describe '#new' do
    it 'creates a new connector' do
      name = mock(:name)
      options = mock(:options)
      PartyResource::Connector.new(name, options)
      PartyResource::Connector(name).ancestors.should be_include(PartyResource::Connector::Base)
    end
  end
end
