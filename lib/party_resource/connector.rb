module PartyResource
  def self.Connector(name = nil)
    Connector.lookup(name)
  end

  class Connector
    def self.lookup(name)
      return default if name.nil?
    end

    def self.default
    end
  end
end
