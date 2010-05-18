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
        HTTParty.get(request.path, data(request))
      end

    private

      def data(request)
        data = options
        data = data.merge(:query => request.data) unless request.data.empty?
        data
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
