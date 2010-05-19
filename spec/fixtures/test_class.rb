PartyResource::Connector.new(:my_connector, {:base_uri => 'http://myserver/path', :username => 'fred', :password => 'pass'})

class TestClass < OpenStruct
  include PartyResource

  connect :find, :get => '/find/:id.ext', :with => :id, :on => :class
#     => Class method find(id)
#     => Returns a SomethingRemote instance
#     => Tells the connector to fetch /things/?id=<id>

  connect :update, :put => '/update/:var.ext', :on => :instance
end

