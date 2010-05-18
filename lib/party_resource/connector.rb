require 'httparty'
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

    class Base
      class << self
        private :new
        attr :options

        def options=(options)
          @options = {}
          @options[:base_uri] = HTTParty.normalize_base_uri(options[:base_uri]) if options.has_key?(:base_uri)

          if options.has_key?(:username) || options.has_key?(:password)
            @options[:basic_auth] = {:username => options[:username], :password => options[:password]}
          end
        end
      end

      include HTTParty
    end
  end

end
