module PartyResource
  module Buildable

    def builder
      Builder.new(@options[:as])
    end

    class Builder
      def initialize(build_options)
        @build_options = build_options
      end

      def call(raw_result, context)
        return nil if raw_result.nil?
        return raw_result.map{ |value| builder.call(value, context) } if map_result?(raw_result)
        builder.call(raw_result, context)
      end

      private
      def builder
        return lambda {|raw_result, context| raw_result} if wants_raw_result?
        return lambda {|raw_result, context| return_type(context).send(return_method,raw_result) } if wants_object?
        return lambda {|raw_result, context| @build_options.call(raw_result) }
      end

      def map_result?(result)
        result.is_a?(Array) && !wants_raw_result?
      end

      def wants_raw_result?
        return_type == :raw
      end

      def wants_object?
        @build_options.is_a?(Array) || @build_options.is_a?(Class) || @build_options == :self
      end

      def return_type(context=nil)
        return_type = @build_options.is_a?(Array) ? @build_options.first : @build_options
        if return_type == :self
          return_type = context.is_a?(Class) ? context : context.class
        end
        return_type
      end

      def return_method
        @build_options.is_a?(Array) ? @build_options.last : :new
      end

    end
  end
end
