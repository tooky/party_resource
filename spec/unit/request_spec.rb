require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))

describe PartyResource::Request do

  subject { PartyResource::Request.new(verb, path, context, args) }
  let_mock(:context, :parameter_values => {})
  let_mock(:verb)
  let_mock(:value)

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

  context 'for a GET request' do
    let(:verb) { :get }
    let_mock(:args)
    its(:http_data) { { :query => args } }

    context 'with no data' do
      let(:args) { {} }
      its(:http_data) { { :body => args } }
    end
  end

  [:post, :put, :delete].each do |http_verb|
    context "for a #{http_verb} request" do
      let(:verb) { http_verb }
      let(:args) { {:param => value} }
      its(:http_data) { { :body => args } }
    end

    context 'with no data' do
      let(:args) { {} }
      its(:http_data) { { :body => args } }
    end
  end

end
