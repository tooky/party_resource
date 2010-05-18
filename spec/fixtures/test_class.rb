PartyResource::Connector.new(:my_connector, {:base_uri => 'http://myserver/path', :username => 'fred', :password => 'pass'})

class TestClass < OpenStruct
  extend PartyResource

  connect :find, :get => '/things/:id.ext', :with => :id, :on => :class
#     => Class method find(id)
#     => Returns a SomethingRemote instance
#     => Tells the connector to fetch /things/?id=<id>

  connect :save, :put => '/things/:id.ext', :on => :instance
end

