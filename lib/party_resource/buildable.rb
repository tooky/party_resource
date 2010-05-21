module PartyResource
  module Buildable

    def builder
      Builder.new(@options[:as])
    end

    class Builder
      def initialize(build_options)
        @build_options = build_options
      end

      def call(raw_result)
        return nil if raw_result.nil?
        builder.call(raw_result)
      end

      def builder
        return lambda {|raw_result| raw_result} if wants_raw_result?
        return lambda {|raw_result| return_type.send(return_method,raw_result) } if wants_object?
        @build_options
      end

      def wants_raw_result?
        return_type == :raw
      end

      def wants_object?
        @build_options.is_a?(Array) || @build_options.is_a?(Class)
      end

      def return_type
        @build_options.is_a?(Array) ? @build_options.first : @build_options
      end

      def return_method
        @build_options.is_a?(Array) ? @build_options.last : :new
      end

    end
  end
end
