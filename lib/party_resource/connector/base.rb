require 'httparty'
module PartyResource
  module Connector

    class Base

      def initialize(name, options)
        set_base_uri(options)
        set_basic_auth(options)
        set_headers(options)
        @name = name
      end

      def send_request(request)
        params = request.http_data(options)
        log_request(request, params)
        HTTParty.send(request.verb, request.path, params)
      end

      def fetch(request)
        response = send_request(request)
        return response if successful_response?(response.code)
        raise PartyResource::Exceptions::ConnectionError.build(response)
      end

      def options
        @options ||= {}
      end

    private
      def successful_response?(code)
        (200..399).include? code
      end

      def log_request(request, params)
        log "** PartyResource #{request.verb.to_s.upcase} call to #{request.path} with #{params.inspect}"
      end

      def log(message)
        unless PartyResource.logger.nil?
          if PartyResource.logger.is_a? Proc
            PartyResource.logger.call message
          else
            PartyResource.logger.debug message
          end
        end
      end

      def set_base_uri(options)
        set_option(:base_uri, HTTParty.normalize_base_uri(options[:base_uri])) if options.has_key?(:base_uri)
      end

      def set_basic_auth(options)
        if requires_basic_auth(options)
          set_option(:basic_auth, :username => options[:username], :password => options[:password])
        end
      end

      def set_headers(options)
        set_option(:headers, options[:headers]) if options.has_key?(:headers)
      end

      def requires_basic_auth(options)
        options.has_key?(:username) || options.has_key?(:password)
      end

      def set_option(key, value)
        self.options[key] = value
      end

    end

  end
end
