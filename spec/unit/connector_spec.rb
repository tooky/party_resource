require 'spec_helper'

describe PartyResource::Connector do
  describe '#lookup' do

    let(:test_connector) { mock(:connector) }
    let(:default_connector) { mock(:connector) }
    let(:connectors) { { :test => test_connector, :other => default_connector } }

    before do
      PartyResource::Connector.repository.stub(:connectors => connectors)
    end

    it "returns the named connectors" do
      PartyResource::Connector.lookup(:test).should == test_connector
    end

    it "returns the default connector for nil name" do
      PartyResource::Connector.repository.stub(:default => :other)

      PartyResource::Connector.lookup(nil).should == default_connector
    end
  end

  describe '#default=' do
    it 'sets the default connector name' do
      name = mock(:name)
      PartyResource::Connector.default = name
      PartyResource::Connector.repository.default.should == name
    end
  end

  describe '#new' do
    let_mock(:name)
    let_mock(:options)
    let_mock(:connector)

    before do
      @repository = PartyResource::Connector::Repository.new
      PartyResource::Connector.stub(:repository => @repository)
      PartyResource::Connector::Base.stub(:new => connector)
    end

    it 'creates a new connector' do
      PartyResource::Connector::Base.should_receive(:new).with(name, options).and_return(connector)
      PartyResource::Connector.new(name, options)
      PartyResource::Connector(name).should == connector
    end

    it 'sets the default if it is currently unset' do
      name2 = mock(:name2)
      PartyResource::Connector.new(name, options)
      PartyResource::Connector.repository.default.should == name
      PartyResource::Connector.new(name2, options)
      PartyResource::Connector.repository.default.should == name
    end
  end
end

