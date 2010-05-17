require 'spec_helper'

describe PartyResource::Route do
  subject { PartyResource::Route.new options }
  let(:path) { mock(:path) }
  let(:object) { mock(:object) }

  def self.it_builds_the_request_path
    it "builds the request path" do
      PartyResource::Path.should_receive(:new).with(path, object)
      subject.call(object)
    end
  end

  context "for a get request" do
    let(:options) { { :get => path } }

    describe ".call" do
      it_builds_the_request_path
    end
  end

  context "for a post request" do
    let(:options) { { :post => path } }

    describe ".call" do
      it_builds_the_request_path
    end
  end

  context 'with more than one verb passed' do
    let(:options) { { :post => path, :get => path } }

    describe ".call" do
      it "raises an argument error" do
        lambda{ subject.call(object) }.should raise_error(ArgumentError)
      end
    end
  end
end
