class OtherClass < TestBaseClass
  def self.make_boolean(data)
    data =~ /OK/
  end
end


class OtherPartyClass
  include PartyResource
  party_connector :other_connector

  connect :test, :get => '/url', :as => :raw

  property :thing

  def initialize(args)
    populate_properties(args)
  end
end
