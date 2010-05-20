PartyResource::Connector.new(:my_connector, {:base_uri => 'http://myserver/path', :username => 'fred', :password => 'pass'})

class TestClass < TestBaseClass
  include PartyResource

  connect :find, :get => '/find/:id.ext', :with => :id, :on => :class

  connect :update, :put => '/update/:var.ext', :on => :instance, :as => OtherClass

  connect :save, :post => '/save/file', :with => :data, :as => :raw

  connect :destroy, :delete => '/delete', :as => [OtherClass, :make_boolean]

  connect :foo, :get => '/foo', :with => :value, :as => lambda {|data| "New #{data} Improved" }

  connect :fetch_json, :get => '/big_data', :as => [TestClass, :from_json]

  property :value, :from => :input_name

  property :value2, :value3

  def self.from_json(args)
    obj = self.new
    obj.send(:populate_properties, args)
    obj
  end

end

