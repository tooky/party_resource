require 'spec_helper'

describe 'Exceptions' do

  describe PartyResource::ConnectionError do
    subject { PartyResource::ConnectionError }

    describe 'build' do
      let(:built) { subject.build(data) }
      let_mock(:data)

      it 'builds ResourceNotFound' do
        data.stub(:code => 404)
        built.should be_a(PartyResource::ResourceNotFound)
      end

      it 'builds ResourceInvalid' do
        data.stub(:code => 422)
        built.should be_a(PartyResource::ResourceInvalid)
      end

      it 'builds ClientError' do
        data.stub(:code => 400)
        built.should be_a(PartyResource::ClientError)
      end

      it 'builds ServerError' do
        data.stub(:code => 500)
        built.should be_a(PartyResource::ServerError)
      end
    end
  end

end
