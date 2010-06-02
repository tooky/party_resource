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
        params = request.http_data(options)
        log "** PartyResource #{request.verb.to_s.upcase} call to #{request.path} with #{params.inspect}"
        response = HTTParty.send(request.verb, request.path, params)
        unless (200..399).include? response.code
          raise PartyResource::Exceptions::ConnectionError.build(response)
        end
        response
      end

    private

      def log(message)
        unless PartyResource.logger.nil?
          if PartyResource.logger.is_a? Proc
            PartyResource.logger.call message
          else
            PartyResource.logger.debug message
          end
        end
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
