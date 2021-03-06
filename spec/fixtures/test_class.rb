PartyResource::Connector.add(:other_connector, {:base_uri => 'http://otherserver/'})
PartyResource::Connector.add(:my_connector, {:base_uri => 'http://myserver/path', :username => 'fred', :password => 'pass', :default => true, :headers => {"Content-type" => "test/header-value"}})

class TestClass < TestBaseClass
  include PartyResource

  connect :find, :get => '/find/:id.ext', :with => :id, :on => :class

  connect :update, :put => '/update/:var.ext', :on => :instance, :as => OtherClass

  connect :save, :post => '/save/file', :with => :data, :as => :raw

  connect :destroy, :delete => '/delete', :as => [OtherClass, :make_boolean]

  connect :foo, :get => '/foo', :with => :value, :as => lambda {|data| "New #{data} Improved" }

  connect :fetch_json, :get => '/big_data', :as => [:self, :from_json], :rescue => {'ResourceNotFound' => nil}

  connect :include, :get => '/include', :on => :instance, :as => OtherClass, :including => {:thing => :value2}

  property :value, :from => :input_name

  property :value2, :value3

  property :nested_value, :from => [:block, :var]

  property :other, :as => OtherClass

  property :processed, :as => lambda { |data| "Processed: #{data}" }, :to => :output_name

  property :child, :as => OtherPartyClass

  def self.from_json(args)
    obj = self.new
    obj.send(:populate_properties, args)
    obj
  end

end

class InheritedTestClass < TestClass
  property :child_property
end

