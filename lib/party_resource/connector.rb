require 'party_resource/connector/base'
module PartyResource
  def self.Connector(name = nil)
    Connector.lookup(name)
  end

  module Connector
    def self.lookup(name)
      name ||= repository.default
      repository.connectors[name]
    end

    def self.default=(name)
      repository.default = name
    end

    def self.new(name, options)
      repository.new_connector(name, options)
    end

    def self.repository
      @repository ||= Repository.new
    end

    class Repository
      attr_accessor :default

      def connectors
        @connectors ||= {}
      end

      def new_connector(name, options)
        connectors[name] = Class.new(Base)
        self.default = name if default.nil?
      end

    end

  end
end
