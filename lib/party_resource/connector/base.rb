require 'httparty'
module PartyResource
  module Connector

    class Base
      attr :options

      def initialize(name, options)
        self.options = options
        @name = name
      end

      [:get, :post, :put, :delete].each do |verb|
        define_method verb do |path|
          HTTParty.send(verb, path.url, path.params)
        end
      end

    private
      def options=(options)
        @options = {}
        @options[:base_uri] = HTTParty.normalize_base_uri(options[:base_uri]) if options.has_key?(:base_uri)

        if options.has_key?(:username) || options.has_key?(:password)
          @options[:basic_auth] = {:username => options[:username], :password => options[:password]}
        end
      end

    end

  end
end
