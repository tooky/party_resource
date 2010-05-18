require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))

describe PartyResource::Request do

  subject { PartyResource::Request.new(verb, path, context, args) }

  context 'with static path' do
    let_mock(:context)
    let(:path) { 'mypath/file.json' }
    let(:args) { {} }
    let_mock(:verb)

    its(:verb) { should == verb }
    its(:path) { should == path }
    its(:data) { should == {} }

  end

  context 'with a parameter' do
    let_mock(:context)
    let(:path) { 'mypath/file.json' }
    let_mock(:value)
    let(:args) { {:param => value} }
    let_mock(:verb)

    its(:verb) { should == verb }
    its(:path) { should == path }
    its(:data) { should == args }

  end

end
