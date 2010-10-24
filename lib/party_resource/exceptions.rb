module PartyResource

  module Exceptions
    Error = Class.new(StandardError)

    class MissingParameter < Error
      def initialize(parameter, context)
        @parameter = parameter
        @context = context
      end

      def to_s
        "No value for #{@parameter} is available in #{@context}"
      end
    end

    class NoConnector < Error
      def initialize(name)
        @name = name
      end

      def to_s
        "Connector '#{@name}' has not been defined"
      end
    end

    class ConnectionError < Error;
      attr_reader :data

      def self.build(data=nil)
        klass = case data.code
          when 404 then ResourceNotFound
          when 422 then ResourceInvalid
          when 400..499 then ClientError
          when 500..599 then ServerError
          else self
        end
        klass.new(data)
      end

      def initialize(data=nil)
        super()
        @data = data
      end

      def to_s
        code = ''
        code = "#{data.code} " rescue nil
        "A #{code}connection error occured"
      end
    end

    ClientError = Class.new(ConnectionError) # 4xx
    ServerError = Class.new(ConnectionError) # 5xx

    ResourceNotFound = Class.new(ClientError) # 404
    ResourceInvalid = Class.new(ClientError) # 422
  end
end
