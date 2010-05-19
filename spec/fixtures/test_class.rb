PartyResource::Connector.new(:my_connector, {:base_uri => 'http://myserver/path', :username => 'fred', :password => 'pass'})

class TestClass < OpenStruct
  include PartyResource

  connect :find, :get => '/find/:id.ext', :with => :id, :on => :class

  connect :update, :put => '/update/:var.ext', :on => :instance, :as => OtherClass

  connect :save, :put => '/save/file', :with => :data, :as => :raw

  def ==(other)
    self.class == other.class && super
  end
end

