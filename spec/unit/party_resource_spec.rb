require File.expand_path(File.join(__FILE__, '..', '..', 'spec_helper'))

describe "PartyResource" do

  subject do
    Class.new().send(:include, PartyResource)
  end
  let(:object) { subject.new }

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
        PartyResource::Route.should_receive(:new).with({:values => other_options, :connector => nil, :as => klass})
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

      context 'with a connector set' do
        before do
          subject.party_connector :foo
        end

        it 'passes the connector name to the route' do
          PartyResource::Route.should_receive(:new).with(hash_including(:connector => :foo))
          subject.connect :new_resource_method, {}
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
        PartyResource::Route.should_receive(:new).with({:others => other_options, :connector => nil, :as => :self})
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

  describe 'properties' do
    let_mock(:v1)
    let_mock(:v2)
    it 'populates property values from hash' do
      subject.property :name, :name2
      object.send(:populate_properties, :name => v1, :name2 => v2)
      object.name.should == v1
      object.name2.should == v2
    end

    it 'renames properties from passed data' do
      subject.property :name, :from => :input_name
      object.send(:populate_properties, :input_name => v1, :name => v2)
      object.name.should == v1
    end

    it 'reaches inside nested values' do
      subject.property :name, :from => [:parent, :input_name]
      object.send(:populate_properties, :parent => { :input_name => v1 }, :input_name => v2)
      object.name.should == v1
    end

    it 'falls back to populating based on the property name if from is not found' do
      subject.property :name, :from => :input_name
      object.send(:populate_properties, :name => v2)
      object.name.should == v2
    end

    it 'does not try to build nil values' do
      klass = Class.new
      subject.property :name, :as => klass
      klass.should_not_receive(:new)
      object.send(:populate_properties, :name => nil)
      object.name.should == nil
    end

    it "doesn't set properties to nil if they aren't in the data hash" do
      subject.property :name, :name2
      object.send(:populate_properties, :name => v1)
      object.name.should == v1
      object.name2.should == nil
      object.send(:populate_properties,:name2 => v2)
      object.name.should == v1
      object.name2.should == v2
    end

    it 'returns a hash representation of properties' do
      subject.property :name, :name2
      object.send(:populate_properties, :name => v1, :name2 => v2)
      object.to_properties_hash.should == {:name => v1, :name2 => v2}
    end

    it 'does not include nil values in the properties hash' do
      subject.property :name, :name2
      object.send(:populate_properties, :name => v1)
      object.to_properties_hash.should == {:name => v1}
    end

    it 'translates propery names to input names' do
      subject.property :name, :from => :input_name
      object.send(:populate_properties, :name => v1)
      object.to_properties_hash.should == {:input_name => v1}
    end

    it 'translates propery names to nested input names' do
      subject.property :name, :from => [:block, :input_name]
      object.send(:populate_properties, :name => v1)
      object.to_properties_hash.should == {:block => {:input_name => v1}}
    end

    it 'translates property names to their required output names' do
      subject.property :name, :to => :output_name
      subject.property :name2, :to => [:block, :output_name]
      object.send(:populate_properties, :name => v1, :name2 => v2)
      object.to_properties_hash.should == {:output_name => v1, :block => {:output_name => v2}}
    end
  end

  describe '#properties_equal?' do
    let_mock(:v1)
    let(:object2) { subject.new }

    before do
      subject.property :name, :name2
      object.send(:populate_properties, :name => v1, :name2 => nil)
    end

    it 'returns true if all properties are equal' do
      subject.property :name, :name2
      object.send(:populate_properties, :name => v1, :name2 => nil)
      object2.send(:populate_properties, :name => v1)
      object.should be_properties_equal(object2)
    end

    it 'returns false if all properties are not equal' do
      object2.send(:populate_properties, :name => v1, :name2 => v1)
      object.should_not be_properties_equal(object2)
    end

    it 'returns false if the other object does not respond to all required properties' do
      object.should_not be_properties_equal(Object.new)
    end
  end


end

