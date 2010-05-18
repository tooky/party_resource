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

    before do
      @repository = PartyResource::Connector::Repository.new
      PartyResource::Connector.stub(:repository => @repository)
    end

    it 'creates a new connector' do
      PartyResource::Connector.new(name, options)
      PartyResource::Connector(name).ancestors.should be_include(PartyResource::Connector::Base)
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

describe PartyResource::Connector::Base do
  describe "#options" do
    subject { PartyResource::Connector::Base }

    let_mock(:username)
    let_mock(:password)
    let_mock(:normalized_uri)
    let_mock(:original_uri)

    before do
      HTTParty.stub(:normalize_base_uri => normalized_uri)
    end

    context "with a base_uri" do
      let(:options) { { :base_uri => original_uri } }

      it 'normalizes the base_uri' do
        HTTParty.should_receive(:normalize_base_uri).with(original_uri)
        subject.options = options
        subject.options.should == {:base_uri => normalized_uri }
      end
    end

    context 'with username' do
      let(:options) { { :username => username } }

      it 'stores the username' do
        subject.options = options
        subject.options.should == {:basic_auth => {:username => username, :password => nil} }
      end
    end

    context 'with password' do
      let(:options) { { :password => password } }

      it 'stores the password' do
        subject.options = options
        subject.options.should == {:basic_auth => {:password => password, :username => nil} }
      end
    end

    context 'with all options' do
      let(:options) { { :base_uri => original_uri, :username => username, :password => password } }

      it 'stores the options' do
        subject.options = options
        subject.options.should == {:base_uri => normalized_uri, :basic_auth => {:password => password, :username => username } }
      end
    end
  end
end
