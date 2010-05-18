require 'spec_helper'

describe PartyResource::Request do

  subject { Request.new(context, path, args) }

  context 'with static path' do
    let_mock(:context)
    let(:path) { 'mypath/file.json' }
    let_mock(:args)

  end

end
