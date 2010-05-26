require 'party_resource/connector/base'
module PartyResource
  module Connector
    class << self
      # Find connector by name
      # @return [Connector::Base] the requested connector
      def lookup(name)
        name ||= repository.default
        connector = repository.connectors[name]
        raise Exceptions::NoConnector.new(name) if connector.nil?
        connector
      end

      # Add a new named connector
      def add(name, options)
        repository.new_connector(name, options)
      end

      private
      def default=(name)
        repository.default = name
      end

      def repository
        @repository ||= Repository.new
      end
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
