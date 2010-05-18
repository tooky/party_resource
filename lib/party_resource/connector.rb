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

    def self.new(name, options)
      Base.new_connector(name, options)
    end

    class Base
      class << self
        attr_accessor :default

        def connectors
          @connectors ||= {}
        end

        def new_connector(name, options)
          connectors[name] = Class.new(Base)
        end

      end

      private :initialize

    end
  end

end
