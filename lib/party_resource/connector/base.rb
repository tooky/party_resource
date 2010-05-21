require 'httparty'
module PartyResource
  module Connector

    class Base
      attr :options

      def initialize(name, options)
        self.options = options
        @name = name
      end

      def fetch(request)
        response = HTTParty.send(request.verb, request.path, request.http_data(options))
        unless (200..399).include? response.code
          raise PartyResource::ConnectionError.build(response)
        end
        response
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
