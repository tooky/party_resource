class OtherClass < TestBaseClass
  def self.make_boolean(data)
    data =~ /OK/
  end
end


class OtherPartyClass
  include PartyResource

  property :thing

  def initialize(args)
    populate_properties(args)
  end
end
