require File.expand_path(File.join(__FILE__, '..', '..', '..', 'spec_helper'))

describe PartyResource::Connector::Base do
  describe "creation" do
    subject { PartyResource::Connector::Base.new(:test, options) }

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
        subject.options.should == {:base_uri => normalized_uri }
      end
    end

    context 'with username' do
      let(:options) { { :username => username } }

      it 'stores the username' do
        subject.options.should == {:basic_auth => {:username => username, :password => nil} }
      end
    end

    context 'with password' do
      let(:options) { { :password => password } }

      it 'stores the password' do
        subject.options.should == {:basic_auth => {:password => password, :username => nil} }
      end
    end

    context 'with all options' do
      let(:options) { { :base_uri => original_uri, :username => username, :password => password } }

      it 'stores the options' do
        subject.options.should == {:base_uri => normalized_uri, 
                                   :basic_auth => {:password => password, :username => username } }
      end
    end
  end

  describe '#fetch' do
    let(:options) { {:base_uri => 'http://myserver.test/path'} }
    let_mock(:data, :empty? => false)
    let_mock(:path)
    let_mock(:return_data, :code => 200)
    let(:request) { mock(:request, :path => path, :verb => verb, :http_data => data) }

    subject { PartyResource::Connector::Base.new(:test, options) }

    [:put, :post, :delete, :get].each do |http_verb|
      context "for #{http_verb} requests" do
        let(:verb) { http_verb }
        it "fetches the request using HTTParty" do
          HTTParty.should_receive(verb).with(path, data).and_return(return_data)
          subject.fetch(request).should == return_data
        end

      end
    end

    context 'error cases' do
      let(:request) { mock(:request, :path => mock(:path), :verb => :get, :http_data => mock(:data)) }

      it 'raises an exception' do
        return_data = mock(:data, :code => 404)
        HTTParty.should_receive(:get).and_return(return_data)
        lambda{ subject.fetch(request) }.should raise_error(PartyResource::ConnectionError)
      end
    end

  end

end
