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
        HTTParty.send(request.verb, request.path, data(request))
      end

    private

      def data(request)
        data = options
        data = data.merge(params_key(request.verb) => request.data) unless request.data.empty?
        data
      end

      def params_key(verb)
        verb == :get ? :query : :body
      end

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
