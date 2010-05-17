require 'spec_helper'

describe PartyResource::Route do
  subject { PartyResource::Route.new options }
  let(:path) { mock(:path) }

  context "for a get request" do
    let(:options) { { :get => path } }

    describe ".call" do
      let(:object) { mock(:object) }

      it "builds the request path" do
        PartyResource::Path.should_receive(:new).with(path, object)
        subject.call(object)
      end
    end
  end
end
