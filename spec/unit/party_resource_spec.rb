require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))

describe "PartyResource" do

  subject do
    Class.new().send(:include, PartyResource)
  end

  describe '.connect' do

    let(:route) { mock(:route) }
    let_mock(:other_options)

    before do
      PartyResource::Route.stub(:new => route)
    end

    context 'for a class level route' do
      let_mock(:klass)

      it "creates a class method matching the name" do
        subject.connect :new_resource_method
        should respond_to(:new_resource_method)
      end

      it "creates a new route" do
        options = {:values => other_options, :as => klass}
        PartyResource::Route.should_receive(:new).with({:values => other_options, :as => klass})
        subject.connect :new_resource_method, options
      end

      context 'the created method' do

        before { subject.connect :new_resource_method }

        it 'calls the route with the class and the arguments' do
          args = [mock(:arg), mock(:arg)]
          route.should_receive(:call).with(subject, *args)

          subject.new_resource_method args[0], args[1]
        end

      end
    end

    context 'for an instance level route' do

      it "creates an instance method matching the name" do
        subject.connect :new_resource_method, :on => :instance
        subject.new.should respond_to(:new_resource_method)
      end

      it "creates a new route" do
        options = {:on => :instance, :others => other_options}
        PartyResource::Route.should_receive(:new).with({:others => other_options, :as => subject})
        subject.connect :new_resource_method, options
      end

      context 'the created method' do

        before { subject.connect :new_resource_method, :on => :instance }

        it 'calls the route with the class and the arguments' do
          args = [mock(:arg), mock(:arg)]
          object = subject.new
          route.should_receive(:call).with(object, *args)

          object.new_resource_method args[0], args[1]
        end

      end
    end
  end

  describe '.Connector' do
    context 'with name == nil' do
      it 'returns the default connector' do
        connector = mock(:connector)
        PartyResource::Connector.should_receive(:lookup).with(nil).and_return(connector)
        PartyResource::Connector(nil).should == connector
      end
    end

    context 'with a name given' do
      it 'returns the requested connector' do
        connector = mock(:connector)
        name = mock(:name)
        PartyResource::Connector.should_receive(:lookup).with(name).and_return(connector)
        PartyResource::Connector(name).should == connector
      end
    end
  end

  describe '.parameter_values' do
    let_mock(:v1)
    let_mock(:v2)
    let_mock(:v3)
    it 'returns internal values for requested variables' do
      subject.stub(:v1 => v1, :v2 => v2, :v3 => v3)
      subject.parameter_values([:v1, :v3]).should == {:v1 => v1, :v3 => v3}
    end

    it 'raises a MissingParameter error' do
      subject.stub(:v1 => v1)
      lambda { subject.parameter_values([:v1, :vx]) }.should raise_error(PartyResource::MissingParameter)
    end
  end
end

