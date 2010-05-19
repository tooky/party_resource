PartyResource::Connector.new(:my_connector, {:base_uri => 'http://myserver/path', :username => 'fred', :password => 'pass'})

class TestClass < TestBaseClass
  include PartyResource

  connect :find, :get => '/find/:id.ext', :with => :id, :on => :class

  connect :update, :put => '/update/:var.ext', :on => :instance, :as => OtherClass

  connect :save, :post => '/save/file', :with => :data, :as => :raw

  connect :destroy, :delete => '/delete', :as => [OtherClass, :make_boolean]

  connect :foo, :get => '/foo', :as => lambda {|data| "New #{data} Improved" }

end

