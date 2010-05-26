require 'party_resource/connector/base'
module PartyResource
  def self.Connector(name = nil)
    Connector.lookup(name)
  end

  module Connector
    def self.lookup(name)
      name ||= repository.default
      connector = repository.connectors[name]
      raise Exceptions::NoConnector.new(name) if connector.nil?
      connector
    end

    def self.default=(name)
      repository.default = name
    end

    def self.add(name, options)
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
        connectors[name] = Base.new(name, options)
        self.default = name if default.nil? || options[:default]
      end

    end

  end
end
