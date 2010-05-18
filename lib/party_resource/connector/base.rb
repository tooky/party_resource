require 'httparty'
module PartyResource
  module Connector
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
