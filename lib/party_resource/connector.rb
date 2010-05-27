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
      # @param [Symbol] name Name for new connector
      # @param [Hash] options
      # @option options [String] :base_uri ('') URI to append to all routes using this connector
      # @option options [String] :username HTTP basic auth username
      # @option options [String] :password HTTP basic auth password
      # @option options [Boolean] :default (false) Set this connector as the default
      # @example
      #   PartyResource::Connector.add(:other_connector, {:base_uri => 'http://otherserver/'})
      # @example
      #   PartyResource::Connector.add(:my_connector, {:base_uri => 'http://myserver/path', :username => 'fred', :password => 'pass', :default => true})

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
