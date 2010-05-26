require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))

describe PartyResource::Connector do
  describe '#lookup' do

    let(:test_connector) { mock(:connector) }
    let(:default_connector) { mock(:connector) }
    let(:connectors) { { :test => test_connector, :other => default_connector } }

    before do
      PartyResource::Connector.send(:repository).stub(:connectors => connectors)
    end

    it "returns the named connectors" do
      PartyResource::Connector.lookup(:test).should == test_connector
    end

    it "returns the default connector for nil name" do
      PartyResource::Connector.send(:repository).stub(:default => :other)

      PartyResource::Connector.lookup(nil).should == default_connector
    end

    it 'raises a NoConnector error it the connector could not be found' do
      lambda { PartyResource::Connector.lookup(:missing_name) }.should raise_error(PartyResource::Exceptions::NoConnector)
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
      options.stub(:[]).with(:default).and_return(false)
    end

    it 'creates a new connector' do
      PartyResource::Connector::Base.should_receive(:new).with(name, options).and_return(connector)
      PartyResource::Connector.add(name, options)
      PartyResource::Connector.lookup(name).should == connector
    end

    it 'sets the default if it is currently unset' do
      name2 = mock(:name2)
      PartyResource::Connector.add(name, options)
      PartyResource::Connector.send(:repository).default.should == name

      PartyResource::Connector.add(name2, options)
      PartyResource::Connector.send(:repository).default.should == name
    end

    it 'sets the default if the default option is set' do
      name2 = mock(:name2)
      PartyResource::Connector.add(name, options)
      PartyResource::Connector.repository.default.should == name

      options.stub(:[]).with(:default).and_return(true)
      PartyResource::Connector.add(name2, options)
      PartyResource::Connector.repository.default.should == name2
    end
  end
end

