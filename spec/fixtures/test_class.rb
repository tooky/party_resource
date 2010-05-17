 class TestClass < OpenStruct
   extend PartyResource

   connect :find, :get => '/things/:id', :with => :id, :on => :class
#     => Class method find(id)
#     => Returns a SomethingRemote instance
#     => Tells the connector to fetch /things/?id=<id>

   connect :save, :put => '/things/:id', :on => :instance
 end

