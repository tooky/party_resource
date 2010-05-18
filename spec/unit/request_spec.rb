require 'spec_helper'

describe PartyResource::Request do

  subject { PartyResource::Request.new(verb, path, context, args) }

  context 'GET with static path' do
    let_mock(:context)
    let(:path) { 'mypath/file.json' }
    let(:args) { [] }
    let_mock(:verb)

    its(:verb) { should == verb }
    its(:path) { should == path }
    its(:data) { should == {} }

  end

end
