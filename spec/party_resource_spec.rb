require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "PartyResource" do

  subject do
    Class.new().extend PartyResource
  end

  describe '.connect' do

    let(:connection) { mock(:connection) }

    before do
      PartyResource::Connection.stub(:new => connection)
    end

    context 'for a class level connection' do

      it "creates a class method matching the name" do
        subject.connect :new_resource_method
        should respond_to(:new_resource_method)
      end

      it "creates a new connection" do
        options = {:values => mock(:options)}
        PartyResource::Connection.should_receive(:new).with(options)
        subject.connect :new_resource_method, options
      end

      context 'the created method' do

        before { subject.connect :new_resource_method }

        it 'calls the connection with the class and the arguments' do
          args = [mock(:arg), mock(:arg)]
          connection.should_receive(:call).with(subject, *args)

          subject.new_resource_method args[0], args[1]
        end

      end
    end

    context 'for an instance level connection' do

      it "creates an instance method matching the name" do
        subject.connect :new_resource_method, :on => :instance
        subject.new.should respond_to(:new_resource_method)
      end

      it "creates a new connection" do
        options = {:on => :instance, :others => mock(:options)}
        PartyResource::Connection.should_receive(:new).with(options)
        subject.connect :new_resource_method, options
      end

      context 'the created method' do

        before { subject.connect :new_resource_method, :on => :instance }

        it 'calls the connection with the class and the arguments' do
          args = [mock(:arg), mock(:arg)]
          object = subject.new
          connection.should_receive(:call).with(object, *args)

          object.new_resource_method args[0], args[1]
        end

      end
    end
  end
end


# class SomethingRemote
#   include PartyResource
#
#   connector 
#
#   connect :find, :get => '/things/', :with => :id, :on => :class
#     => Class method find(id)
#     => Returns a SomethingRemote instance
#     => Tells the connector to fetch /things/?id=<id>

#   connect :save, :put => '/things/:id', :on => :instance
# end
