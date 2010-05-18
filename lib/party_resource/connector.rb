module PartyResource
  def self.Connector(name = nil)
    Connector.lookup(name)
  end

  module Connector
    def self.lookup(name)
      name ||= Base.default
      Base.connectors[name]
    end

    def self.default=(name)
      Base.default = name
    end

    class Base
      class << self
        attr_accessor :default
      end

    end
  end

end
