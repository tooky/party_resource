require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))

describe PartyResource::Request do

  subject { PartyResource::Request.new(verb, path, context, args, params) }
  let_mock(:context, :parameter_values => {})
  let_mock(:verb)
  let_mock(:value)
  let(:params) { {} }
  let(:path) { '/path' }

  context 'with static path' do
    let(:path) { 'mypath/file.json' }
    let(:args) { {} }

    its(:verb) { should == verb }
    its(:path) { should == path }
    its(:data) { should == {} }

    it "should merge http_data with passed options" do
      subject.http_data(:foo => :bar).should == { :foo => :bar }
    end
  end

  context 'with a parameter' do
    let(:path) { 'mypath/file.json' }
    let(:args) { {:param => value} }

    its(:verb) { should == verb }
    its(:path) { should == path }
    its(:data) { should == args }
  end

  context 'with a parameter referenced in the path' do
    let(:path) { 'mypath/:param.json' }
    let(:args) { {:param => 'THE_VALUE', :second => value} }

    its(:verb) { should == verb }
    its(:path) { should == 'mypath/THE_VALUE.json' }
    its(:data) { should == {:second => value } }
  end

  context 'with an object variable referenced in the path' do
    let_mock(:context, :parameter_values => {:var => 'THE_VALUE'})
    let(:path) { 'mypath/:param/:var.json' }
    let(:args) { {:param => 'PARAM_VALUE', :second => value} }

    its(:verb) { should == verb }
    its(:path) { should == 'mypath/PARAM_VALUE/THE_VALUE.json' }
    its(:data) { should == { :second => value } }
    it 'asks the context object for required data values' do
      context.should_receive(:parameter_values).with([:var])
      subject.path
    end
  end

  context 'with extra parameters' do
    let(:path) { '/path/:id' }
    let_mock(:p1)
    let_mock(:p2)
    let_mock(:a1)
    let_mock(:a2)
    let(:params) { {:id => mock(:id2), :param => p1, :param2 => p2} }
    let(:args) { {:id => 'THE_ID', :param => a1, :arg2 => a2} }
    it 'merges them into the request data' do
      subject.path.should == '/path/THE_ID'
      subject.data.should == {:param => a1, :param2 => p2, :arg2 => a2}
    end
  end

  context 'for a GET request' do
    let(:verb) { :get }
    let_mock(:args)
    its(:http_data) { { :query => args } }

    context 'with no data' do
      let(:args) { {} }
      its(:http_data) { should == {} }
    end
  end

  [:post, :put, :delete].each do |http_verb|
    context "for a #{http_verb} request" do
      let(:verb) { http_verb }
      let(:args) { {:param => value} }
      its(:http_data) { should == { :body => args } }
    end

    context 'with no data' do
      let(:args) { {} }
      its(:http_data) { should == {} }
    end
  end

  context 'encoding the path' do
    let(:args) { {} }
    let(:path) { '/path needing encoding' }
    it 'encodes the path' do
      subject.path.should == '/path%20needing%20encoding'
    end
  end

end
