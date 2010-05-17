module PartyResource
  def self.Connector(name = nil)
    Connector.lookup(name)
  end

  module Connector
    def self.lookup(name)
      name ||= Base.default
      Base.connectors[name]
    end

    class Base
    end
  end

end
